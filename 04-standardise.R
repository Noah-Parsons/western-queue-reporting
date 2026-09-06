# 04-standardise.R -- direction-of-bias estimate.
#
# Question: the published western median duration is computed from the ~12% of
# withdrawals that carry a withdrawal date. 03-differences.R shows that subset
# is compositionally unlike the region. How far does that move the median?
#
# Three stages:
#   A  calibrate how technology and cohort shift duration, in the ISO regions
#      where date coverage is near-complete and selection is not a concern;
#   B  validate the reweighting estimator inside those same regions, where the
#      answer is known;
#   C  apply it to the West and report the shift, with a truncation-matched
#      sensitivity that is treated as co-primary.

source("00-setup.R")
set.seed(20260906)
dir.create("results", showWarnings = FALSE)

queue <- read_queue()
B_BOOT <- 2000     # bootstrap replicates
B_VALID <- 500     # validation replicates
MIN_CELL <- 5      # cells thinner than this are flagged

# ---- coverage: why these four regions -------------------------------------

coverage <- queue |>
  filter(q_status == "withdrawn") |>
  add_duration() |>
  group_by(region) |>
  summarise(withdrawn = n(), dated = sum(dated),
            pct = round(100 * dated / n(), 1), .groups = "drop") |>
  arrange(desc(pct))
write.csv(coverage, "results/coverage.csv", row.names = FALSE)
cat("=== WITHDRAWAL-DATE COVERAGE BY REGION ===\n")
print(as.data.frame(coverage))
cat("\nCalibration set:", paste(ISO_GOOD, collapse = ", "), "(all >= 90% coverage).\n")
cat("SPP (73%), ERCOT and NYISO (~49%) and the Southeast (35%) are excluded:\n")
cat("their own duration statistics rest on selected subsets too.\n")

# ---- stage A: what moves duration, where we can see it --------------------

iso <- build_iso(queue) |> mutate(lmw = log(pmax(mw_1, 1)))
iso$tech   <- relevel(iso$tech, "Solar")
iso$cohort <- relevel(iso$cohort, "<=2014")

fit <- lm(log(dur + 1/12) ~ tech + cohort + lmw, data = iso)
iso_coef <- data.frame(
  term       = names(coef(fit)),
  estimate   = round(coef(fit), 4),
  multiplier = round(exp(coef(fit)), 3),
  se         = round(summary(fit)$coefficients[, 2], 4),
  p          = signif(summary(fit)$coefficients[, 4], 3),
  row.names  = NULL
)
write.csv(iso_coef, "results/iso_calibration.csv", row.names = FALSE)
cat("\n=== STAGE A: ISO CALIBRATION (n =", nrow(iso), ") ===\n")
print(iso_coef)
cat("\nR-squared:", round(summary(fit)$r.squared, 4), "\n")
cat("Technology, cohort and size together explain about",
    round(100 * summary(fit)$r.squared), "% of the variance in\n")
cat("duration where we can measure it well. This is why the reweighting below\n")
cat("moves the median so little.\n")

# Multiplicative cell offsets implied by the calibration, at median size.
cells <- expand.grid(tech = factor(TECH_LEVELS, levels = TECH_LEVELS),
                     cohort = factor(COHORT_LEVELS, levels = COHORT_LEVELS),
                     stringsAsFactors = FALSE)
cells$lmw <- median(iso$lmw, na.rm = TRUE)
cells$offset <- exp(predict(fit, newdata = cells))

# ---- the two estimators ---------------------------------------------------

# Design-based post-stratification: reweight the observed durations so that
# each cell carries its share of the target population rather than its share
# of the reporting subset. Cells with no observed duration are dropped and the
# weights renormalised; `covered` records how much target weight survives.
poststrat <- function(obs, target) {
  tg <- target |> count(cohort, tech, name = "n_tgt") |>
    mutate(w = n_tgt / sum(n_tgt))
  ob <- obs |> group_by(cohort, tech) |> mutate(n_obs = n()) |> ungroup() |>
    inner_join(tg, by = c("cohort", "tech")) |> mutate(wt = w / n_obs)
  have <- unique(paste(ob$cohort, ob$tech))
  list(median  = weighted_quantile(ob$dur, ob$wt),
       covered = sum(tg$w[paste(tg$cohort, tg$tech) %in% have]))
}

# Model-assisted transport: divide each observed duration by its cell's
# calibrated offset to strip the composition out, then re-attach the offsets
# of the target composition. Uses every observation in every target cell, so
# it does not depend on cell-level coverage -- at the cost of assuming the ISO
# offset structure carries over to the West.
transport <- function(obs, target) {
  o <- obs |> left_join(cells[c("tech", "cohort", "offset")],
                        by = c("tech", "cohort"))
  resid <- o$dur / o$offset
  tg <- target |> count(cohort, tech, name = "n_tgt") |>
    mutate(w = n_tgt / sum(n_tgt)) |>
    left_join(cells[c("tech", "cohort", "offset")], by = c("tech", "cohort"))
  vals <- as.vector(outer(resid, tg$offset))
  wts  <- rep(tg$w / length(resid), each = length(resid))
  weighted_quantile(vals, wts)
}

# ---- stage B: does the estimator work where we know the answer? -----------
#
# Draw ISO subsamples whose technology-by-cohort composition matches the
# West's reporting subset, then ask whether reweighting recovers the true
# full-ISO median that the biased subsample misses.

west <- build_west(queue)
wd   <- west |> filter(withdrawn, !is.na(cohort))
dated_shares <- wd |> filter(dated) |> count(cohort, tech, name = "n") |>
  mutate(share = n / sum(n))

iso_c <- iso |> filter(!is.na(cohort))
truth <- median(iso_c$dur)
iso_cells <- split(seq_len(nrow(iso_c)), paste(iso_c$cohort, iso_c$tech))
key   <- paste(dated_shares$cohort, dated_shares$tech)
avail <- key %in% names(iso_cells)
take  <- round(600 * dated_shares$share[avail] / sum(dated_shares$share[avail]))

valid <- t(replicate(B_VALID, {
  idx <- unlist(Map(function(k, n) {
    pool <- iso_cells[[k]]
    if (n <= 0) integer(0) else sample(pool, min(n, length(pool)))
  }, key[avail], take))
  samp <- iso_c[idx, ]
  c(naive = median(samp$dur),
    ps    = poststrat(samp, iso_c)$median,
    tr    = transport(samp, iso_c))
}))

cat("\n=== STAGE B: VALIDATION INSIDE THE ISO REGIONS ===\n")
cat("True full-ISO median duration:", round(truth, 3), "years\n")
cat("Subsamples of ~600 drawn to match the West's dated composition,",
    B_VALID, "replicates.\n\n")
labs <- c(naive = "biased subsample (naive)",
          ps    = "  + post-stratification",
          tr    = "  + model-assisted transport")
cat(sprintf("%-30s %8s %8s %8s\n", "estimator", "mean", "bias", "RMSE"))
for (nm in colnames(valid)) {
  v <- valid[, nm]
  cat(sprintf("%-30s %8.3f %8.3f %8.3f\n", labs[nm], mean(v),
              mean(v) - truth, sqrt(mean((v - truth)^2))))
}
write.csv(data.frame(truth = truth, estimator = colnames(valid),
                     mean = colMeans(valid),
                     bias = colMeans(valid) - truth,
                     rmse = sqrt(colMeans((valid - truth)^2))),
          "results/validation.csv", row.names = FALSE)

# ---- stage C: apply to the West -------------------------------------------

run_basis <- function(obs, label, target) {
  naive <- median(obs$dur)
  ps <- poststrat(obs, target)
  tr <- transport(obs, target)

  boot <- replicate(B_BOOT, {
    bs <- obs[sample(nrow(obs), nrow(obs), TRUE), ]
    nb <- median(bs$dur)
    c(poststrat(bs, target)$median - nb, transport(bs, target) - nb)
  })

  data.frame(
    basis = label, n_obs = nrow(obs), n_target = nrow(target),
    naive_median = round(naive, 3),
    estimator = c("post-stratification", "model-assisted transport"),
    standardised = round(c(ps$median, tr), 3),
    shift = round(c(ps$median, tr) - naive, 3),
    ci_lo = round(apply(boot, 1, quantile, 0.025), 3),
    ci_hi = round(apply(boot, 1, quantile, 0.975), 3),
    covered_pct = round(100 * c(ps$covered, 1), 2)
  )
}

main <- rbind(
  run_basis(wd |> filter(dated), "dated records", wd),
  run_basis(wd |> filter(dated, reports), "reporting entities", wd)
)
cat("\n=== STAGE C: THE WEST, UNRESTRICTED ===\n")
print(main, row.names = FALSE)

# Truncation-matched. Requests entering in 2022 or later cannot yet display a
# long duration, and they are 26% of the target but 14% of the dated subset.
# Restricting to cohorts with at least four years of exposure and capping
# durations at four years removes that mechanism entirely.
CAP <- 4
wd_tr <- wd |> filter(q_year <= 2021) |> mutate(dur = pmin(dur, CAP))
trunc <- rbind(
  run_basis(wd_tr |> filter(dated), "dated records", wd_tr),
  run_basis(wd_tr |> filter(dated, reports), "reporting entities", wd_tr)
)
cat("\n=== STAGE C: TRUNCATION-MATCHED (cohorts <= 2021, capped at", CAP, "y) ===\n")
print(trunc, row.names = FALSE)

main$window  <- "unrestricted"
trunc$window <- paste0("cohorts <=2021, capped at ", CAP, "y")
bias <- rbind(main, trunc)
write.csv(bias, "results/bias_estimate.csv", row.names = FALSE)

# ---- cell diagnostics -----------------------------------------------------

cell_tab <- wd |>
  group_by(cohort, tech) |>
  summarise(target = n(),
            med = ifelse(any(dated), round(median(dur[dated]), 2), NA_real_),
            dated = sum(dated),
            .groups = "drop") |>
  select(cohort, tech, target, dated, med)
write.csv(cell_tab, "results/cells.csv", row.names = FALSE)
cat("\n=== CELL DIAGNOSTICS (target n / dated n) ===\n")
print(as.data.frame(cell_tab |> mutate(cell = paste0(target, "/", dated)) |>
        select(cohort, tech, cell) |>
        pivot_wider(names_from = tech, values_from = cell)))
thin <- cell_tab$dated < MIN_CELL
cat("\ncells with fewer than", MIN_CELL, "dated records:", sum(thin), "of",
    nrow(cell_tab), "- carrying",
    round(100 * sum(cell_tab$target[thin]) / sum(cell_tab$target), 1),
    "% of target weight\n")
cat("cells with no dated record at all:", sum(cell_tab$dated == 0), "- carrying",
    round(100 * sum(cell_tab$target[cell_tab$dated == 0]) / sum(cell_tab$target), 2),
    "%\n")
