# 05-logistic.R -- withdrawal as a binary outcome across all western requests.
#
# The duration analysis in 04-standardise.R can only use the ~12% of
# withdrawals that carry a date. Withdrawal itself is recorded for every
# request, so this model uses all 8,097 -- no dates required. It asks which
# project attributes predict withdrawal, and how much of the variation is
# attributable to the provider rather than to the project.
#
# Entity causes complete separation for a handful of small providers that have
# either no withdrawals or nothing but. The primary specification therefore
# treats entity as a random intercept, which shrinks those providers instead of
# dropping them; a fixed-effects fit is reported alongside.

source("00-setup.R")
suppressMessages(library(lme4))
set.seed(20260906)
dir.create("results", showWarnings = FALSE)

west <- build_west()

cat("=== SAMPLE ===\n")
cat("western requests:", nrow(west), "\n")
print(table(west$q_status))
cat("\nOutcome: withdrawn vs everything else (active, operational, suspended,\n")
cat("unknown). Withdrawal rate:", round(100 * mean(west$withdrawn), 1), "%\n")
cat("missing capacity (mw_1):", sum(is.na(west$mw_1)),
    "  missing queue year:", sum(is.na(west$q_year)), "\n")

# Model frame: complete cases on the four predictors.
mf <- west |>
  filter(!is.na(mw_1), !is.na(q_year)) |>
  mutate(
    lmw    = log(pmax(mw_1, 1)),
    tech   = relevel(tech, "Solar"),
    cohort = relevel(cohort, "<=2014"),
    entity = factor(entity)
  )
cat("model frame:", nrow(mf), "requests (",
    nrow(west) - nrow(mf), "dropped for missing predictors )\n")

# ---- separation diagnostic ------------------------------------------------

sep <- mf |>
  group_by(entity) |>
  summarise(n = n(), wd = sum(withdrawn), .groups = "drop") |>
  mutate(separated = wd == 0 | wd == n)
cat("\n=== SEPARATION ===\n")
cat("entities with no variation in the outcome:", sum(sep$separated),
    "covering", sum(sep$n[sep$separated]), "requests\n")
print(as.data.frame(sep |> filter(separated) |> arrange(desc(n))))

# ---- primary: entity as a random intercept --------------------------------

m_re <- glmer(withdrawn ~ tech + lmw + cohort + (1 | entity),
              data = mf, family = binomial,
              control = glmerControl(optimizer = "bobyqa",
                                     optCtrl = list(maxfun = 2e5)))

cat("\n=== PRIMARY MODEL: mixed-effects logistic, entity random intercept ===\n")
print(summary(m_re))

fe <- summary(m_re)$coefficients
or_re <- data.frame(
  model     = "random-intercept",
  term      = rownames(fe),
  odds_ratio = round(exp(fe[, 1]), 3),
  ci_lo      = round(exp(fe[, 1] - 1.96 * fe[, 2]), 3),
  ci_hi      = round(exp(fe[, 1] + 1.96 * fe[, 2]), 3),
  p          = signif(fe[, 4], 3),
  row.names  = NULL
)
cat("\n--- odds ratios ---\n")
print(or_re)

vc <- as.numeric(VarCorr(m_re)$entity)
icc <- vc / (vc + pi^2 / 3)
cat("\nentity variance:", round(vc, 3), " SD:", round(sqrt(vc), 3),
    "\nintraclass correlation:", round(icc, 3),
    "-- the share of latent variation in withdrawal\nrisk that sits between",
    "providers rather than between projects.\n")

# ---- sensitivity: entity as fixed effects ---------------------------------
#
# Providers with fewer than 25 requests are pooled; separated providers are
# dropped, since their coefficients are not identified.

drop_ent <- sep$entity[sep$separated]
mf_fe <- mf |>
  filter(!entity %in% drop_ent) |>
  mutate(entity = {
    n_by <- table(entity)
    factor(ifelse(n_by[as.character(entity)] >= 25,
                  as.character(entity), "Other (small)"))
  }) |>
  mutate(entity = relevel(entity, "PacifiCorp"))

m_fe <- glm(withdrawn ~ tech + lmw + cohort + entity,
            data = mf_fe, family = binomial)
cat("\n=== SENSITIVITY: fixed-effects logistic (",
    nrow(mf_fe), "requests, ", length(drop_ent),
    "separated providers dropped ) ===\n")
cf <- summary(m_fe)$coefficients
or_fe <- data.frame(
  model      = "fixed-effects",
  term       = rownames(cf),
  odds_ratio = round(exp(cf[, 1]), 3),
  ci_lo      = round(exp(cf[, 1] - 1.96 * cf[, 2]), 3),
  ci_hi      = round(exp(cf[, 1] + 1.96 * cf[, 2]), 3),
  p          = signif(cf[, 4], 3),
  row.names  = NULL
)
print(or_fe)

# ---- sensitivity: strict outcome ------------------------------------------
#
# Suspended and unknown requests are neither clearly withdrawn nor clearly
# alive. Dropping them tests whether the coding choice matters.

mf_strict <- mf |> filter(!q_status %in% c("suspended", "unknown"))
m_strict <- glmer(withdrawn ~ tech + lmw + cohort + (1 | entity),
                  data = mf_strict, family = binomial,
                  control = glmerControl(optimizer = "bobyqa",
                                         optCtrl = list(maxfun = 2e5)))
cs <- summary(m_strict)$coefficients
or_strict <- data.frame(
  model      = "strict outcome",
  term       = rownames(cs),
  odds_ratio = round(exp(cs[, 1]), 3),
  ci_lo      = round(exp(cs[, 1] - 1.96 * cs[, 2]), 3),
  ci_hi      = round(exp(cs[, 1] + 1.96 * cs[, 2]), 3),
  p          = signif(cs[, 4], 3),
  row.names  = NULL
)
cat("\n=== SENSITIVITY: suspended and unknown dropped (",
    nrow(mf_strict), "requests ) ===\n")
print(or_strict)

# ---- sensitivity: equal exposure ------------------------------------------
#
# The cohort coefficients above are contaminated by exposure time: a request
# filed in 2024 has had two years in which to be withdrawn, one filed in 2010
# has had fifteen. Restricting to cohorts with at least four years of exposure
# does not remove the problem but bounds it, and shows whether the technology
# and capacity effects -- which are the substantive ones -- survive.

mf_exp <- mf |> filter(q_year <= 2021)
m_exp <- glmer(withdrawn ~ tech + lmw + cohort + (1 | entity),
               data = mf_exp, family = binomial,
               control = glmerControl(optimizer = "bobyqa",
                                      optCtrl = list(maxfun = 2e5)))
ce <- summary(m_exp)$coefficients
or_exp <- data.frame(
  model      = "equal exposure (<=2021)",
  term       = rownames(ce),
  odds_ratio = round(exp(ce[, 1]), 3),
  ci_lo      = round(exp(ce[, 1] - 1.96 * ce[, 2]), 3),
  ci_hi      = round(exp(ce[, 1] + 1.96 * ce[, 2]), 3),
  p          = signif(ce[, 4], 3),
  row.names  = NULL
)
cat("\n=== SENSITIVITY: cohorts with >= 4 years of exposure (",
    nrow(mf_exp), "requests ) ===\n")
print(or_exp)
cat("\nWithdrawal rate by cohort, showing the exposure problem directly:\n")
print(as.data.frame(mf |> group_by(cohort) |>
  summarise(n = n(), withdrawn = sum(withdrawn),
            rate = round(100 * sum(withdrawn) / n(), 1),
            median_years_exposure = round(2026 - median(q_year), 1),
            .groups = "drop")))

# ---- model comparison and fit --------------------------------------------

m_null    <- glmer(withdrawn ~ (1 | entity), data = mf, family = binomial,
                   control = glmerControl(optimizer = "bobyqa"))
m_noent   <- glm(withdrawn ~ tech + lmw + cohort, data = mf, family = binomial)

cat("\n=== WHAT CARRIES THE PREDICTION ===\n")
cat("project attributes only (no entity), AIC:", round(AIC(m_noent), 1), "\n")
cat("entity only (no attributes),       AIC:", round(AIC(m_null), 1), "\n")
cat("both,                              AIC:", round(AIC(m_re), 1), "\n")
cat("\nlikelihood-ratio test, adding project attributes to an entity-only model:\n")
print(anova(m_null, m_re))

pred <- predict(m_re, type = "response")
cat("\nin-sample accuracy at 0.5:",
    round(100 * mean((pred > 0.5) == mf$withdrawn), 1), "%  (base rate",
    round(100 * max(mean(mf$withdrawn), 1 - mean(mf$withdrawn)), 1), "%)\n")

write.csv(rbind(or_re, or_fe, or_strict, or_exp), "results/logistic.csv", row.names = FALSE)
write.csv(data.frame(entity_variance = vc, entity_sd = sqrt(vc), icc = icc,
                     aic_attributes_only = AIC(m_noent),
                     aic_entity_only = AIC(m_null),
                     aic_both = AIC(m_re),
                     n = nrow(mf)),
          "results/logistic_fit.csv", row.names = FALSE)
