library(readxl)
excel_sheets("data/LBNL_Ix_Queue_Data_File_thru2025.xlsx")
read_excel("data/LBNL_Ix_Queue_Data_File_thru2025.xlsx",
           sheet = "03. Complete Queue Data",
           n_max = 5,
           col_names = FALSE)
queue <- read_excel("data/LBNL_Ix_Queue_Data_File_thru2025.xlsx",
                    sheet = "03. Complete Queue Data",
                    skip = 1)
dim(queue)
names(queue)
library(dplyr)
count(queue, q_status)
count(queue, region)
queue |> filter(region == "West") |> count(state, sort = TRUE)
west <- queue |> filter(region == "West")
count(west, q_status)
summary(west$q_date)
summary(west$wd_date)
sum(west$q_status == "withdrawn" & is.na(west$wd_date))
west |> filter(q_status == "withdrawn") |>
  group_by(state) |>
  summarise(n = n(), missing = sum(is.na(wd_date)), pct = round(100*missing/n)) |>
  arrange(desc(n))
west |> filter(q_status == "withdrawn") |>
  group_by(q_year) |>
  summarise(n = n(), missing = sum(is.na(wd_date)), pct = round(100*missing/n)) |>
  arrange(q_year) |>
  print(n = 30)
west |> filter(q_status == "withdrawn") |>
  group_by(entity) |>
  summarise(n = n(), have_date = sum(!is.na(wd_date)), pct = round(100*have_date/n)) |>
  arrange(desc(n)) |>
  print(n = 60)
ent <- west |> filter(q_status == "withdrawn") |>
  group_by(entity) |>
  summarise(wd_n = n(), wd_dated = sum(!is.na(wd_date)), .groups = "drop") |>
  mutate(reports = wd_dated / wd_n >= 0.25)

west2 <- west |>
  left_join(select(ent, entity, reports), by = "entity") |>
  mutate(reports = ifelse(is.na(reports), FALSE, reports))

west2 |> filter(q_status == "withdrawn") |>
  group_by(reports) |>
  summarise(n = n(),
            entities = n_distinct(entity),
            median_mw = median(mw_1, na.rm = TRUE),
            mean_mw = round(mean(mw_1, na.rm = TRUE), 1),
            median_qyear = median(q_year, na.rm = TRUE))
west2 |> filter(q_status == "withdrawn") |>
  count(reports, type_clean) |>
  group_by(reports) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  arrange(reports, desc(n)) |>
  print(n = 40)
wd <- west2 |> filter(q_status == "withdrawn")

chisq.test(table(wd$reports, wd$type_clean == "Solar"))

wilcox.test(q_year ~ reports, data = wd)

wilcox.test(mw_1 ~ reports, data = wd)