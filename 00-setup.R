# 00-setup.R -- shared data preparation.
#
# Carries forward the definitions established interactively in 01-explore.R
# and 02-figures.R so that 03/04/05 cannot drift from them. 01-explore.R is
# left as the exploratory record; this file is what the analysis scripts use.

suppressMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
})

QUEUE_FILE <- "data/LBNL_Ix_Queue_Data_File_thru2025.xlsx"
QUEUE_SHEET <- "03. Complete Queue Data"

# Regions whose withdrawal-date coverage is high enough to treat observed
# durations as approximately complete (all >= 90%; see 03-standardise.R).
ISO_GOOD <- c("CAISO", "ISO-NE", "MISO", "PJM")

# Six technology groups, as in 02-figures.R.
TECH_LEVELS <- c("Solar", "Wind", "Solar+Battery", "Battery", "Gas", "Other")
tech6 <- function(x) {
  factor(ifelse(x %in% TECH_LEVELS[1:5], x, "Other"), levels = TECH_LEVELS)
}

# Four queue cohorts. Cut so that every bin carries >= 14% of western
# withdrawals, 2019-21 isolates the queue surge, and 2022+ isolates the
# cohorts whose durations are still administratively truncated.
COHORT_LEVELS <- c("<=2014", "2015-18", "2019-21", "2022+")
cohort4 <- function(y) {
  cut(y, breaks = c(-Inf, 2014, 2018, 2021, Inf), labels = COHORT_LEVELS)
}

# Entity is treated as reporting if it records a withdrawal date for at least
# a quarter of its withdrawals (01-explore.R).
REPORTS_THRESHOLD <- 0.25

read_queue <- function(path = QUEUE_FILE) {
  read_excel(path, sheet = QUEUE_SHEET, skip = 1)
}

# Duration in years from interconnection request to withdrawal. `dated` marks
# the records that can enter a duration statistic at all.
add_duration <- function(df) {
  df |>
    mutate(
      dur   = as.numeric(difftime(wd_date, q_date, units = "days")) / 365.25,
      dated = !is.na(wd_date) & !is.na(q_date) & !is.na(dur) & dur >= 0
    )
}

# The western analysis frame: all 8,097 requests, with the entity-level
# reporting flag joined on.
build_west <- function(queue = read_queue()) {
  west <- queue |> filter(region == "West")
  ent <- west |>
    filter(q_status == "withdrawn") |>
    group_by(entity) |>
    summarise(wd_n = n(), wd_dated = sum(!is.na(wd_date)), .groups = "drop") |>
    mutate(reports = wd_dated / wd_n >= REPORTS_THRESHOLD)
  west |>
    left_join(select(ent, entity, reports), by = "entity") |>
    mutate(
      reports    = ifelse(is.na(reports), FALSE, reports),
      tech       = tech6(type_clean),
      cohort     = cohort4(q_year),
      withdrawn  = q_status == "withdrawn"
    ) |>
    add_duration()
}

# The good-coverage ISO frame, used to calibrate how technology and cohort
# shift duration where non-reporting is not a concern.
build_iso <- function(queue = read_queue()) {
  queue |>
    filter(region %in% ISO_GOOD, q_status == "withdrawn", !is.na(q_year)) |>
    mutate(tech = tech6(type_clean), cohort = cohort4(q_year)) |>
    add_duration() |>
    filter(dated)
}

# Weighted quantile: sort, accumulate weight, take the first value at or past p.
weighted_quantile <- function(x, w, p = 0.5) {
  ok <- !is.na(x) & !is.na(w) & w > 0
  x <- x[ok]; w <- w[ok]
  o <- order(x); x <- x[o]; w <- w[o]
  x[which(cumsum(w) / sum(w) >= p)[1]]
}
