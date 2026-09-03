roster <- west |>
  group_by(entity) |>
  summarise(
    requests   = n(),
    withdrawn  = sum(q_status == "withdrawn"),
    wd_dated   = sum(q_status == "withdrawn" & !is.na(wd_date)),
    .groups    = "drop"
  ) |>
  mutate(
    wd_rate    = round(100 * withdrawn / requests, 1),
    dated_rate = round(100 * wd_dated / withdrawn, 1)
  ) |>
  arrange(desc(requests))

print(roster, n = 40)
roster |> filter(withdrawn >= 10) |> summarise(
  entities = n(),
  requests = sum(requests),
  withdrawn = sum(withdrawn),
  dated = sum(wd_dated)
)

roster |> filter(withdrawn >= 10) |> count(dated_rate > 25)
library(ggplot2)

roster |>
  filter(withdrawn >= 10) |>
  ggplot(aes(x = reorder(entity, dated_rate), y = dated_rate)) +
  geom_col() +
  coord_flip() +
  labs(
    x = NULL,
    y = "Withdrawals with a recorded withdrawal date (%)",
    title = "Withdrawal-date reporting by western transmission provider",
    subtitle = "Non-ISO West, entities with 10 or more withdrawals, requests through 2025",
    caption = "Data: LBNL Queued Up 2026 Edition (Berkeley Lab and GridTracker), CC BY 4.0"
  ) +
  theme_minimal()
roster |>
  filter(withdrawn >= 10) |>
  mutate(label = paste0(entity, " (", withdrawn, ")")) |>
  ggplot(aes(x = reorder(label, dated_rate + withdrawn/100000), y = dated_rate)) +
  geom_col() +
  coord_flip() +
  labs(
    x = NULL,
    y = "Withdrawals with a recorded withdrawal date (%)",
    title = "Withdrawal-date reporting by western transmission provider",
    subtitle = "Non-ISO West, entities with 10 or more withdrawals; withdrawal count in parentheses",
    caption = "Data: LBNL Queued Up 2026 Edition (Berkeley Lab and GridTracker), CC BY 4.0"
  ) +
  theme_minimal()
p1 <- last_plot() + theme(plot.margin = margin(10, 10, 10, 20))
p1
mix <- wd |>
  mutate(
    tech = ifelse(type_clean %in% c("Solar", "Wind", "Solar+Battery", "Battery", "Gas"),
                  type_clean, "Other"),
    tech = factor(tech, levels = c("Solar", "Wind", "Solar+Battery", "Battery", "Gas", "Other")),
    group = ifelse(reports, "Reporting (5 entities)", "Non-reporting (19 entities)")
  ) |>
  count(group, tech) |>
  group_by(group) |>
  mutate(pct = 100 * n / sum(n)) |>
  ungroup()

ggplot(mix, aes(x = tech, y = pct, fill = group)) +
  geom_col(position = "dodge") +
  labs(
    x = NULL,
    y = "Share of withdrawn requests (%)",
    fill = NULL,
    title = "Resource mix of withdrawn requests, reporting vs non-reporting providers",
    subtitle = "Non-ISO West, requests through 2025",
    caption = "Data: LBNL Queued Up 2026 Edition (Berkeley Lab and GridTracker), CC BY 4.0"
  ) +
  theme_minimal() +
  theme(legend.position = "top")
ggplot(wd, aes(x = q_year, fill = ifelse(reports, "Reporting", "Non-reporting"))) +
  geom_density(alpha = 0.5) +
  labs(
    x = "Year request entered the queue",
    y = "Density",
    fill = NULL,
    title = "Queue vintage of withdrawn requests, reporting vs non-reporting providers",
    subtitle = "Non-ISO West, requests through 2025",
    caption = "Data: LBNL Queued Up 2026 Edition (Berkeley Lab and GridTracker), CC BY 4.0"
  ) +
  theme_minimal() +
  theme(legend.position = "top")