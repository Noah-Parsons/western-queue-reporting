# 03-differences.R -- roster table, and a pre-specified family of five
# comparisons between the records that carry the published duration statistic
# and the western withdrawals that do not.
#
# Two bases are reported throughout, because they are not the same set:
#   dated  -- withdrawn requests carrying both a queue date and a withdrawal
#             date. This is what the published median literally rests on.
#   entity -- withdrawals filed with the entities that record a withdrawal
#             date for at least a quarter of their withdrawals.

source("00-setup.R")

west <- build_west()
wd   <- west |> filter(withdrawn)
dir.create("results", showWarnings = FALSE)

# ---- roster ---------------------------------------------------------------

roster <- west |>
  group_by(entity) |>
  summarise(
    requests  = n(),
    withdrawn = sum(withdrawn),
    wd_dated  = sum(withdrawn & dated),
    .groups   = "drop"
  ) |>
  mutate(
    wd_rate    = round(100 * withdrawn / requests, 1),
    dated_rate = ifelse(withdrawn > 0, round(100 * wd_dated / withdrawn, 1), NA_real_),
    reporting  = !is.na(dated_rate) & dated_rate >= 100 * REPORTS_THRESHOLD
  ) |>
  arrange(desc(requests))

write.csv(roster, "results/roster.csv", row.names = FALSE)

cat("=== WESTERN ROSTER ===\n")
print(as.data.frame(roster), max = 400)

cat("\n--- the reporting ladder ---\n")
cat("entities in the West:                   ", nrow(roster), "\n")
cat("  ... with at least one withdrawal:     ", sum(roster$withdrawn > 0), "\n")
cat("  ... recording at least one date:      ", sum(roster$wd_dated > 0), "\n")
cat("  ... recording dates for >= 25%:       ", sum(roster$reporting), "\n")
cat("requests in the West:                   ", sum(roster$requests), "\n")
cat("withdrawals in the West:                ", sum(roster$withdrawn), "\n")
cat("withdrawals carrying a usable duration: ", sum(roster$wd_dated),
    sprintf(" (%.1f%%)\n", 100 * sum(roster$wd_dated) / sum(roster$withdrawn)))
cat("  (one of these lacks a queue year and so drops out of the\n",
    "   cohort-stratified analysis in 04-standardise.R)\n", sep = "")

pc <- roster |> filter(entity == "PacifiCorp")
cat("\nPacifiCorp: ", pc$requests, " requests, ", pc$withdrawn, " withdrawals, ",
    pc$wd_dated, " dated (", pc$dated_rate, "%). The largest queue in the region, ",
    "and\nthe reason the ladder reads 6 at 'any date' but 5 at the 25% threshold.\n",
    sep = "")

# ---- the family of five ---------------------------------------------------
#
# Four comparisons are project attributes that the ISO calibration in
# 04-standardise.R shows to move withdrawal duration. The fifth, withdrawal
# rate, is an entity-level property and is tested over all requests.
#
# State is deliberately excluded: the reporting entities are near-perfectly
# confounded with their states (PSCo/CO, PNM/NM, Avista/WA-ID, LADWP/CA,
# EPE/TX), so a state test would only restate the entity split.

# `record_grp` splits withdrawals; `entity_grp` splits all requests. Each basis
# supplies its own natural pair.
bases <- list(
  "dated records" = list(
    record_grp = wd$dated,
    entity_grp = west$entity %in% roster$entity[roster$wd_dated > 0]
  ),
  "reporting entities" = list(
    record_grp = wd$reports,
    entity_grp = west$reports
  )
)

run_family <- function(label, b) {
  tests <- list(
    "technology mix (6 groups)"    = suppressWarnings(chisq.test(table(b$record_grp, wd$tech))),
    "queue cohort mix (4 bins)"    = suppressWarnings(chisq.test(table(b$record_grp, wd$cohort))),
    "capacity (MW)"                = suppressWarnings(wilcox.test(wd$mw_1 ~ b$record_grp)),
    "interconnection service type" = suppressWarnings(chisq.test(table(b$record_grp, wd$service))),
    "withdrawal rate"              = suppressWarnings(chisq.test(table(b$entity_grp, west$withdrawn)))
  )
  out <- data.frame(
    basis      = label,
    comparison = names(tests),
    test       = sapply(tests, function(t) t$method),
    statistic  = round(sapply(tests, function(t) unname(t$statistic)), 2),
    p_raw      = sapply(tests, function(t) t$p.value),
    row.names  = NULL
  )
  out$p_holm  <- p.adjust(out$p_raw, method = "holm")
  out$verdict <- ifelse(out$p_holm < 0.05, "difference", "null")
  out
}

results <- do.call(rbind, Map(run_family, names(bases), bases))
write.csv(results, "results/differences.csv", row.names = FALSE)

cat("\n=== FAMILY OF FIVE COMPARISONS (Holm-adjusted within basis) ===\n")
print(transform(results[c("basis", "comparison", "statistic", "p_raw", "p_holm", "verdict")],
                p_raw  = signif(results$p_raw, 3),
                p_holm = signif(results$p_holm, 3)))

cat("\nRobust across both bases:\n")
agree <- results |>
  group_by(comparison) |>
  summarise(verdicts = paste(sort(unique(verdict)), collapse = "/"), .groups = "drop")
print(as.data.frame(agree))

# ---- descriptives ---------------------------------------------------------

desc <- function(grp, label) {
  wd |>
    group_by(group = grp) |>
    summarise(
      n            = n(),
      solar_pct    = round(100 * mean(tech == "Solar"), 1),
      wind_pct     = round(100 * mean(tech == "Wind"), 1),
      storage_pct  = round(100 * mean(tech %in% c("Battery", "Solar+Battery")), 1),
      gas_pct      = round(100 * mean(tech == "Gas"), 1),
      med_mw       = median(mw_1, na.rm = TRUE),
      med_q_year   = median(q_year, na.rm = TRUE),
      pct_2022plus = round(100 * mean(cohort == "2022+", na.rm = TRUE), 1),
      .groups      = "drop"
    ) |>
    mutate(basis = label, .before = 1)
}
descriptives <- rbind(desc(wd$dated, "dated records"),
                      desc(wd$reports, "reporting entities"))
write.csv(descriptives, "results/descriptives.csv", row.names = FALSE)
cat("\n=== DESCRIPTIVES ===\n")
print(as.data.frame(descriptives))

cat("\n=== WITHDRAWAL RATE DETAIL (explains the split verdict on test 5) ===\n")
print(as.data.frame(
  west |> mutate(any_date_entity = entity %in% roster$entity[roster$wd_dated > 0]) |>
    group_by(any_date_entity) |>
    summarise(requests = n(), n_withdrawn = sum(withdrawn), .groups = "drop") |>
    mutate(rate = round(100 * n_withdrawn / requests, 1))))
print(as.data.frame(
  west |> group_by(reports) |>
    summarise(requests = n(), n_withdrawn = sum(withdrawn), .groups = "drop") |>
    mutate(rate = round(100 * n_withdrawn / requests, 1))))
