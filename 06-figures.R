# 06-figures.R -- the two figures that carry the argument of the write-up.
#
# 02-figures.R produces the three exploratory figures. These two summarise the
# result: how far the reporting subset departs from the region it stands for,
# and how little that departure moves the published median.

source("00-setup.R")
library(ggplot2)

west <- build_west()
wd   <- west |> filter(withdrawn, !is.na(cohort))
dir.create("figures", showWarnings = FALSE)

PAL <- c("the region (all 5,267 withdrawals)" = "#4C6D9C",
         "the reporting subset (636 dated)"   = "#C7772F")
CAP <- paste("Data: LBNL Queued Up 2026 Edition (Berkeley Lab and GridTracker),",
             "CC BY 4.0")

# ---- figure 4: the composition gap ----------------------------------------

share <- function(var, label) {
  rbind(
    wd |> count(level = .data[[var]]) |>
      mutate(pct = 100 * n / sum(n), grp = names(PAL)[1]),
    wd |> filter(dated) |> count(level = .data[[var]]) |>
      mutate(pct = 100 * n / sum(n), grp = names(PAL)[2])
  ) |> mutate(panel = label)
}
gap <- rbind(share("tech", "Technology"), share("cohort", "Queue cohort"))
gap$grp <- factor(gap$grp, levels = names(PAL))

p4 <- ggplot(gap, aes(x = level, y = pct, fill = grp)) +
  geom_col(position = "dodge", width = 0.75) +
  facet_wrap(~panel, scales = "free_x") +
  scale_fill_manual(values = PAL) +
  labs(
    x = NULL, y = "Share of withdrawn requests (%)", fill = NULL,
    title = "The withdrawals that carry a date are not the withdrawals the region files",
    subtitle = paste("Non-ISO West, requests through 2025. Technology and cohort",
                     "mix both differ at p < 1e-14;\ncapacity does not differ."),
    caption = CAP
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "top",
        axis.text.x = element_text(angle = 30, hjust = 1),
        panel.grid.major.x = element_blank())

ggsave("figures/04-composition-gap.png", p4, width = 10, height = 5.5, dpi = 300)

# ---- figure 5: the bias estimate ------------------------------------------

bias <- read.csv("results/bias_estimate.csv", stringsAsFactors = FALSE)
bias$lab <- paste0(bias$basis, "\n", bias$estimator)
bias$window <- factor(bias$window, levels = unique(bias$window))

p5 <- ggplot(bias, aes(x = shift, y = lab, colour = window)) +
  geom_vline(xintercept = 0, linewidth = 0.4, colour = "grey40") +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.18,
                 position = position_dodge(width = 0.55)) +
  geom_point(size = 2.4, position = position_dodge(width = 0.55)) +
  scale_colour_manual(values = c("#4C6D9C", "#C7772F")) +
  labs(
    x = "Change in the median duration after standardising to the region's composition (years)",
    y = NULL, colour = "Observation window",
    title = "Standardising the reporting subset to the region moves the median by less than three months",
    subtitle = paste("Non-ISO West. Points are the shift from the unstandardised median;",
                     "bars are 95% bootstrap intervals\n(2,000 replicates). The sign depends",
                     "on how right-truncation is handled, so the direction is not identified."),
    caption = CAP
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "top", panel.grid.major.y = element_blank())

ggsave("figures/05-bias-estimate.png", p5, width = 10, height = 5.5, dpi = 300)

cat("wrote figures/04-composition-gap.png and figures/05-bias-estimate.png\n")
print(bias[c("window", "basis", "estimator", "naive_median", "standardised",
             "shift", "ci_lo", "ci_hi")], row.names = FALSE)
