# Who Reports Withdrawal Dates in the Western Interconnection Queue, and Does It Matter?

**Noah Parsons**

*Draft, September 2026*

---

## Summary

Berkeley Lab's *Queued Up* series publishes, among much else, a median duration
from interconnection request to withdrawal for each region of the United States.
For the non-ISO West that figure is computed from the withdrawals that carry a
recorded withdrawal date. In the 2026 Edition data file, that is 637 of 5,277
western withdrawals — **12.1%**. The remaining 87.9% are known to have been
withdrawn but not when.

This paper asks whether those 637 records are representative of the region whose
duration they are used to describe, and if not, how far the published median is
displaced as a result.

The answer has three parts.

**First, the reporting is extraordinarily concentrated.** Of the 31 western
transmission providers with at least one withdrawal in the file, six record any
withdrawal date at all and five record one for more than a quarter of their
withdrawals. PacifiCorp — which alone accounts for 2,160 of the region's 8,097
requests and 1,627 of its withdrawals, more than twice the next-largest
provider on either count — records a date for 6.0% of them. The median western
withdrawal duration is, in practice, a statistic about Colorado, New Mexico,
eastern Washington, Los Angeles and El Paso.

**Second, that subset is compositionally unlike the region.** Technology mix,
queue cohort and interconnection service type all differ from the regional
population at p < 10⁻¹¹ after correction for multiple comparisons, on both of
the two defensible definitions of "the reporting subset." Project capacity does
not differ. The dated records over-represent stand-alone solar (44.8% against
31.5%) and wind (30.7% against 23.1%) and under-represent solar-plus-storage
(10.7% against 18.8%) and stand-alone storage (3.6% against 9.0%).

**Third — and this is the part that resists the obvious conclusion — those
compositional differences barely move the median.** Standardising the reporting
subset to the region's actual technology-by-cohort composition shifts the median
by −0.06 years, with a 95% bootstrap interval of [−0.23, +0.00]. Under a
truncation-matched window the shift is +0.19 years. The sign flips. A validation
exercise inside the ISO regions, where date coverage is near-complete and the
answer is therefore known, shows why: deliberately imposing the West's skewed
composition on those regions biases their median by 0.021 years — about eight
days. Technology, cohort and capacity together explain 4.6% of the variance in
withdrawal duration where it can be measured well. Composition is simply not a
strong enough determinant of duration for a composition gap of this size to
matter much.

The correct caveat on the published western median is therefore not "it is
biased by an unrepresentative technology mix." It is "it is computed from one
eighth of the region's withdrawals, drawn from five of thirty-one providers, and
the mechanism by which that might bias it is unmeasured." Composition is the
part we can check, and it is small. What we cannot check is whether providers
that record dates withdraw on a different *schedule* from providers that do not
— and nothing in this data file can settle that.

A companion logistic regression, which needs no dates and therefore uses all
8,097 western requests, finds that solar is the most withdrawal-prone
technology, that larger projects are more likely to be withdrawn, and that 26%
of the latent variation in withdrawal risk sits between providers rather than
between projects.

---

## 1. The question

Interconnection queues have become the binding constraint on adding generation
to the North American grid, and *Queued Up* is the reference description of
them. Its regional summaries are widely cited in regulatory filings, trade
press and academic work. One of those summaries is the typical time a request
spends in the queue before being withdrawn — a natural measure of how much
developer effort the process absorbs before yielding nothing.

Computing that statistic requires two dates: when the request entered the queue,
and when it was withdrawn. The first is recorded almost universally. The second
is not. Transmission providers publish their queues in whatever format they
choose, and many simply drop a withdrawn request from the published list without
recording the date on which it left. The compilers of *Queued Up* can only
report what providers publish.

Where coverage is near-complete this is a non-issue. In the four regions with
the best coverage — ISO-NE, CAISO, PJM and MISO — 94% to 99% of withdrawals
carry a date, so the observed durations are effectively a census. In the non-ISO
West they are 12.1% of withdrawals, and the question of who those 12.1% are
becomes unavoidable.

Two things could go wrong. The reporting subset could differ from the region in
project characteristics that themselves influence how long a request survives —
a subset heavy in wind, say, when wind takes longer to withdraw than solar. Call
this **compositional bias**; it is measurable, because both the composition of
the subset and the composition of the region are observed. Or the providers that
record dates could simply process requests differently from those that do not,
in ways not captured by any recorded project attribute. Call this **provider
process bias**; it is not measurable from this file, because the durations of
the non-reporting providers are exactly what is missing.

This paper measures the first and bounds what can be said about the second.

## 2. Data

The analysis uses a single source: the *Queued Up* 2026 Edition data file
(`LBNL_Ix_Queue_Data_File_thru2025.xlsx`), covering interconnection requests
through the end of 2025, published by Lawrence Berkeley National Laboratory and
GridTracker under CC BY 4.0. Sheet `03. Complete Queue Data` holds project-level
records: 38,201 rows across nine regions.

The `region` field distinguishes the seven ISO/RTO territories, the Southeast,
and "West" — the non-ISO Western Interconnection, i.e. WECC excluding CAISO.
That western region is the study population: **8,097 requests**, of which 5,277
(65.2%) are recorded as withdrawn, 1,603 active, 963 operational, 244 suspended
and 10 unknown.

Four fields carry the analysis. `q_date` and `wd_date` give the request and
withdrawal dates; their difference, in years, is the duration. `type_clean` gives
a cleaned technology label, which I collapse to six groups (Solar, Wind,
Solar+Battery, Battery, Gas, Other), matching the grouping used in the
exploratory figures. `q_year` gives the queue entry year, which I bin into four
cohorts (≤2014, 2015–18, 2019–21, 2022+). `mw_1` gives nameplate capacity, and
`entity` the transmission provider.

A record is **dated** if it carries both a queue date and a withdrawal date and
the resulting duration is non-negative. Six records across the whole file have
withdrawal dates preceding their queue dates and are excluded on that ground.
By this definition 637 of the West's 5,277 withdrawals are dated; one of those
lacks a queue year and so drops out of the cohort-stratified analysis, leaving
636.

Two definitions of "the reporting subset" are carried in parallel throughout,
because they are not the same set and the choice turns out to matter more than
any of the corrections applied to them:

- **dated records** — the 636 withdrawn requests carrying a usable duration.
  This is what the published median literally rests on, irrespective of who
  filed them.
- **reporting entities** — the 539 dated withdrawals filed with the five
  providers that record a date for at least a quarter of their withdrawals.
  This is the institutional unit: the set of providers whose reporting practice
  makes the statistic possible.

The gap between them is exactly 97 dated records, every one of them
PacifiCorp's.

### Table 1: withdrawal-date coverage by region

| Region | Withdrawals | Dated | Coverage |
|---|---:|---:|---:|
| ISO-NE | 982 | 970 | 98.8% |
| CAISO | 2,200 | 2,160 | 98.2% |
| PJM | 5,226 | 5,091 | 97.4% |
| MISO | 3,263 | 3,060 | 93.8% |
| SPP | 1,846 | 1,340 | 72.6% |
| NYISO | 1,531 | 745 | 48.7% |
| ERCOT | 1,158 | 520 | 44.9% |
| Southeast | 2,738 | 845 | 30.9% |
| **West** | **5,277** | **637** | **12.1%** |

The West is not merely the worst-covered region; it is worse by a factor of two
and a half than the next-worst. This ordering also defines the calibration set
used in Section 5: the four regions above 90% coverage.

## 3. The roster

The concentration of reporting is the single most striking feature of the
western data, and it is worth setting out in full before any modelling.

Thirty-six entities appear in the western region. Five have no withdrawals at
all. Of the remaining 31, **six record at least one withdrawal date, and five
record one for at least a quarter of their withdrawals.**

### Table 2: western transmission providers, requests through 2025

Providers with 25 or more requests. `Dated` counts withdrawals carrying a usable
duration; `Rate` is that as a share of the provider's withdrawals.

| Provider | Requests | Withdrawn | Dated | Rate |
|---|---:|---:|---:|---:|
| PacifiCorp | 2,160 | 1,627 | 97 | 6.0% |
| BPA | 998 | 611 | 0 | 0% |
| Idaho Power | 824 | 515 | 0 | 0% |
| APS | 619 | 426 | 0 | 0% |
| NV Energy | 505 | 263 | 0 | 0% |
| NorthWestern | 448 | 328 | 0 | 0% |
| **PSCo** | 408 | 295 | 286 | **96.9%** |
| **PNM** | 356 | 224 | 133 | **59.4%** |
| WAPA-IS | 273 | 194 | 0 | 0% |
| **Avista** | 173 | 117 | 71 | **60.7%** |
| SRP | 155 | 105 | 0 | 0% |
| PSE | 142 | 86 | 0 | 0% |
| TEP | 120 | 84 | 0 | 0% |
| PGE | 114 | 51 | 0 | 0% |
| **LADWP** | 113 | 55 | 36 | **65.5%** |
| WAPA-RM | 110 | 88 | 0 | 0% |
| TSGT | 104 | 14 | 0 | 0% |
| **EPE** | 66 | 30 | 14 | **46.7%** |
| PRPA | 62 | 35 | 0 | 0% |
| BHCT | 51 | 32 | 0 | 0% |
| SRP-ANPP | 45 | 18 | 0 | 0% |
| CLPT | 40 | 13 | 0 | 0% |
| WAPA-DSW | 34 | 0 | 0 | — |
| IID | 33 | 0 | 0 | — |
| SMUD | 33 | 18 | 0 | 0% |
| SRP-PV/PC | 33 | 22 | 0 | 0% |
| BHP | 26 | 7 | 0 | 0% |

Reporting providers in bold. The remaining nine providers have fewer than 25
requests each and none records a date.

The distribution is close to binary. Providers either record dates for roughly
half their withdrawals or better, or they record none whatsoever. PacifiCorp is
the sole exception, and its 6.0% is the reason the count of reporting providers
reads six or five depending on where the line is drawn — a distinction with real
consequences, since PacifiCorp is by a wide margin the largest queue in the
region.

That PacifiCorp is both the largest western queue and a near-total
non-reporter is the central fact of this paper. Its 1,627 withdrawals are 31%
of the region's total, and 2.7 times those of the next-largest provider.
Whatever the typical PacifiCorp withdrawal duration is, it contributes 6% of
its weight to the published median.

Note also the geographic consequence. The five reporting providers serve
Colorado (PSCo), New Mexico and west Texas (PNM, EPE), eastern Washington and
northern Idaho (Avista), and the City of Los Angeles (LADWP). The published
western median describes those service territories. It is nearly silent on
Oregon, Montana, Wyoming, Nevada, Arizona and the Bonneville footprint. I do not
report a formal test of geographic difference, because provider and state are so
nearly collinear in this region that such a test would only restate Table 2.

## 4. Is the reporting subset different?

### 4.1 Method

I test five pre-specified comparisons between the reporting subset and the rest
of the region. Four are project attributes that the ISO calibration in Section 5
shows to influence duration; the fifth is a provider-level property.

1. **Technology mix** — six groups, Pearson χ².
2. **Queue cohort mix** — four bins, Pearson χ².
3. **Capacity** — `mw_1`, Wilcoxon rank-sum.
4. **Interconnection service type** — ERIS / NRIS / NRIS-ERIS / Other, χ².
5. **Withdrawal rate** — the share of all requests ending in withdrawal, χ²,
   computed over all 8,097 requests rather than the withdrawals alone.

Each family of five is Holm-corrected within basis. Both bases (dated records,
reporting entities) receive the full family, giving ten tests in all.

For test 5 each basis takes its natural provider-level analogue: for the dated
basis, providers recording any date (six, including PacifiCorp); for the entity
basis, providers clearing the 25% threshold (five).

### 4.2 Results

### Table 3: the family of five

| Basis | Comparison | Statistic | p (Holm) | Verdict |
|---|---|---:|---:|---|
| dated records | technology mix | χ² = 129.04 | 1.9 × 10⁻²⁵ | **difference** |
| dated records | queue cohort mix | χ² = 70.70 | 9.1 × 10⁻¹⁵ | **difference** |
| dated records | capacity (MW) | W = 1,466,743 | 0.80 | null |
| dated records | service type | χ² = 54.19 | 2.0 × 10⁻¹¹ | **difference** |
| dated records | withdrawal rate | χ² = 101.95 | 2.3 × 10⁻²³ | **difference** |
| reporting entities | technology mix | χ² = 120.19 | 1.1 × 10⁻²³ | **difference** |
| reporting entities | queue cohort mix | χ² = 142.76 | 4.8 × 10⁻³⁰ | **difference** |
| reporting entities | capacity (MW) | W = 1,562,008 | 0.068 | null |
| reporting entities | service type | χ² = 58.54 | 3.6 × 10⁻¹² | **difference** |
| reporting entities | withdrawal rate | χ² = 0.16 | 0.69 | null |

Three comparisons return a difference on both bases: **technology mix, queue
cohort mix and interconnection service type**. One returns a null on both:
**capacity**. One splits: **withdrawal rate**.

The split is instructive rather than awkward. Providers recording any date
withdraw 71.7% of their requests against 60.8% for the rest — but that gap is
entirely PacifiCorp, whose own withdrawal rate is 75.3% and whose 2,160 requests
dominate the group. Restrict to the five genuine reporters and the rates are
64.6% against 65.3%, a difference of seven tenths of a percentage point
(p = 0.69). Providers that actually report dates do not withdraw at an unusual
rate. The apparent effect on the wider definition is one large utility's
idiosyncrasy.

The magnitudes behind the technology and cohort results are shown in Figure 2
and summarised here. Against the regional population of 5,267 withdrawals, the
636 dated records over-represent stand-alone solar (44.8% against 31.5%) and
wind (30.7% against 23.1%), and under-represent solar-plus-storage (10.7%
against 18.8%), stand-alone storage (3.6% against 9.0%), gas (3.5% against 6.5%)
and other technologies (6.8% against 11.2%). On cohort they are close on the
oldest bin (39.3% against 39.6%) but over-represent 2019–21 (22.2% against
14.6%) and under-represent 2022 and later (14.3% against 25.7%).

The shape of this is coherent. Storage and hybrid projects entered western
queues in volume from about 2019, and did so disproportionately in the
territories of the large non-reporting providers. The reporting subset is
therefore both older and more conventional in technology than the region it
stands for.

**Figure 1** (`figures/01-reporting-by-entity.png`) shows the reporting rate for
every western provider with ten or more withdrawals, with withdrawal counts.
**Figure 2** (`figures/04-composition-gap.png`) shows the technology and cohort
gaps side by side.

## 5. How far does the composition gap move the median?

Establishing that the reporting subset is unrepresentative does not establish
that the published median is wrong. That requires knowing how strongly the
attributes that differ actually influence duration — and then reweighting.

The estimation proceeds in three stages: calibrate the influence of technology
and cohort on duration where coverage is good; validate the reweighting
estimator in that same place, where the true answer is known; then apply it to
the West.

### 5.1 Stage A: what moves duration, measured where we can see it

The four regions above 90% coverage — CAISO, ISO-NE, MISO, PJM — supply 11,281
dated withdrawals whose durations are effectively a census rather than a sample.
Regressing log(duration + 1/12) on technology, cohort and log capacity there
gives the following multiplicative effects.

### Table 4: ISO calibration (n = 11,281)

| Term | Multiplier on duration | p |
|---|---:|---:|
| Wind (vs Solar) | 1.447 | 1.5 × 10⁻³⁴ |
| Solar+Battery | 1.144 | 7.1 × 10⁻⁵ |
| Other | 1.076 | 0.043 |
| Battery | 1.031 | 0.27 |
| Gas | 1.005 | 0.88 |
| cohort 2015–18 (vs ≤2014) | 0.849 | 2.4 × 10⁻⁹ |
| cohort 2019–21 | 1.420 | 6.1 × 10⁻³⁷ |
| cohort 2022+ | 1.102 | 0.0022 |
| log capacity (MW) | 1.016 | 0.012 |

Wind withdrawals take about 45% longer than solar; the 2019–21 cohort — the
queue surge that has been working through withdrawal since roughly 2024 — takes
about 42% longer than the pre-2015 cohorts. These are precisely estimated and
substantively real.

**But the model's R² is 0.046.** Technology, cohort and size together account
for under 5% of the variance in how long a request takes to be withdrawn, in the
data where we can measure that variance cleanly. This single number governs
everything that follows: composition can differ a great deal without the median
moving much, because composition is a weak determinant of duration.

### 5.2 Stage B: does the correction work where the answer is known?

Before applying a reweighting estimator to the West, it is worth checking that
it does what it claims on data where the truth is observable.

The true median duration across the four calibration regions is 1.629 years. I
repeatedly draw subsamples of roughly 600 records from those regions,
constructed to match the *West's dated* technology-by-cohort composition — that
is, deliberately distorted in exactly the way the western reporting subset is
distorted. I then ask whether the reweighting recovers 1.629 from the distorted
subsample.

### Table 5: validation inside the calibration regions (500 replicates)

| Estimator | Mean | Bias | RMSE |
|---|---:|---:|---:|
| distorted subsample, uncorrected | 1.650 | +0.021 | 0.051 |
| + post-stratification | 1.633 | +0.004 | 0.052 |
| + model-assisted transport | 1.674 | +0.045 | 0.092 |

Two conclusions. First, post-stratification works: it removes essentially all of
the compositional bias, cutting it from 0.021 to 0.004 years. Second, and far
more important, **the bias it removes is tiny to begin with**. Imposing the
West's composition on a population of 11,281 well-measured durations shifts the
median by 0.021 years — about eight days.

The model-assisted transport estimator, which strips out the calibrated cell
offsets and re-attaches them under the target composition, performs *worse* than
doing nothing. It is reported below for completeness but the validation
disqualifies it as the preferred estimator; post-stratification is the one to
read.

This result is the most consequential in the paper, and it constrains the
conclusion before the western estimate is even computed. Whatever the western
reporting problem is, a composition gap of this magnitude cannot produce a large
displacement in the median.

### 5.3 Stage C: the western estimate

Strata are technology (6) × cohort (4) = 24 cells. Cell coverage is good: only
two cells contain no dated western record, and together they carry 0.08% of the
target weight; eight cells hold fewer than five dated records and carry 5.3%.
Post-stratification weights each observed duration by its cell's share of the
5,267-withdrawal regional population divided by the number of dated records in
that cell, renormalising over covered cells. Confidence intervals come from
2,000 bootstrap replicates of the shift.

### Table 6: standardised medians

| Window | Basis | Estimator | Unstandardised | Standardised | Shift | 95% CI |
|---|---|---|---:|---:|---:|---|
| unrestricted | dated records | post-stratification | 1.830 | 1.766 | **−0.064** | [−0.227, +0.003] |
| unrestricted | dated records | transport | 1.830 | 1.782 | −0.048 | [−0.166, +0.039] |
| unrestricted | reporting entities | post-stratification | 1.552 | 1.418 | **−0.134** | [−0.315, +0.069] |
| unrestricted | reporting entities | transport | 1.552 | 1.437 | −0.115 | [−0.226, −0.005] |
| matched | dated records | post-stratification | 2.136 | 2.327 | **+0.192** | [+0.014, +0.315] |
| matched | dated records | transport | 2.136 | 2.150 | +0.014 | [−0.069, +0.120] |
| matched | reporting entities | post-stratification | 1.808 | 1.925 | **+0.116** | [−0.010, +0.229] |
| matched | reporting entities | transport | 1.808 | 1.727 | −0.082 | [−0.223, 0.000] |

"Matched" restricts to cohorts entering in 2021 or earlier and caps durations at
four years, for reasons given in 5.4. **Figure 3**
(`figures/05-bias-estimate.png`) plots all eight.

Read the post-stratification rows. On the unrestricted window the median falls
from 1.83 to 1.77 years — a shift of about three weeks, with an interval that
includes zero. On the matched window it rises from 2.14 to 2.33 — about ten
weeks, with an interval that excludes zero. The two windows disagree in sign.

Note also what dwarfs both corrections. Moving from the dated-records basis to
the reporting-entities basis moves the unstandardised median from 1.83 to 1.55
years — 0.28 years, four times the size of the unrestricted standardisation
shift. **The definitional choice of which records count as "the reporting
subset" moves the answer considerably more than correcting that subset's
composition does.** Any published duration statistic for this region carries
that definitional sensitivity whether or not it acknowledges it.

### 5.4 Why the sign is not identified

Duration here is not a complete measurement. A request entering the queue in
2023 cannot display a five-year withdrawal duration, because five years have not
elapsed. The observation window is bounded above by the file's cutoff, and that
bound bites harder on recent cohorts.

This interacts directly with the composition gap. The 2022+ cohort is 25.7% of
the regional population but only 14.3% of the dated subset. Reweighting
therefore transfers a quarter of the weight onto the cohort whose durations are
most severely truncated — which mechanically pulls the median down, regardless
of any genuine difference in how long those projects take.

The matched window removes that mechanism: restricting to cohorts entering by
2021 gives every remaining record at least four years of exposure, and capping
durations at four years makes the measurement identical across cohorts. Under
that restriction the shift is positive.

Both estimates are defensible and they disagree. The unrestricted estimate
targets exactly the quantity *Queued Up* publishes, and inherits its truncation.
The matched estimate is a cleaner contrast but describes a different, more
restricted quantity, discarding 26% of the regional population to get there.
Neither is wrong; they answer slightly different questions, and the answers have
opposite signs.

The honest reading is therefore: **the compositional bias in the published
western median is small — under three months on any specification, and under
one month on the specification that matches the published estimand — and its
direction is not identified by this data.** Given the validation result in
Table 5, which puts the compositional bias at about eight days when measured
against a known truth, the small magnitude is the robust finding and the sign is
noise around it.

## 6. Withdrawal as a binary outcome

The duration analysis is confined to 12% of western withdrawals. Withdrawal
*itself* is recorded for every request, so a model of whether a request is
withdrawn can use the entire region without needing a single date. This is a
different question — what predicts withdrawal, not how long it takes — but it is
answerable on the full population, and it speaks to how much of the variation in
queue outcomes is attributable to the provider.

### 6.1 Specification

The outcome is withdrawal against everything else (active, operational,
suspended, unknown). Predictors are technology (six groups, solar as reference),
log capacity, cohort (four bins) and entity. Of 8,097 requests, 7,991 have
complete predictors; the 106 exclusions all lack a queue year.

Entity requires care. Seven providers, covering 90 requests, show no variation
in the outcome — five have no withdrawals at all, two have nothing but — and so
cannot be assigned an identified coefficient in a fixed-effects logistic model.
The primary specification therefore treats entity as a random intercept, which
shrinks such providers toward the grand mean rather than dropping them, and
retains all 7,991 requests. A fixed-effects fit, with those seven providers
dropped and providers under 25 requests pooled, is reported alongside; so are
fits dropping the ambiguous suspended and unknown statuses, and restricting to
cohorts with at least four years of exposure.

### 6.2 Results

### Table 7: odds of withdrawal, mixed-effects logistic (n = 7,991)

| Term | Odds ratio | 95% CI | p |
|---|---:|---|---:|
| Wind (vs Solar) | 0.547 | [0.458, 0.652] | 1.9 × 10⁻¹¹ |
| Solar+Battery | 0.578 | [0.487, 0.685] | 2.7 × 10⁻¹⁰ |
| Battery | 0.521 | [0.428, 0.635] | 9.9 × 10⁻¹¹ |
| Gas | 0.355 | [0.282, 0.447] | 9.5 × 10⁻¹⁹ |
| Other | 0.314 | [0.264, 0.373] | 4.6 × 10⁻³⁹ |
| log capacity (MW) | 1.129 | [1.089, 1.170] | 3.2 × 10⁻¹¹ |
| cohort 2015–18 (vs ≤2014) | 0.610 | [0.516, 0.721] | 7.6 × 10⁻⁹ |
| cohort 2019–21 | 0.446 | [0.374, 0.531] | 2.0 × 10⁻¹⁹ |
| cohort 2022+ | 0.344 | [0.293, 0.403] | 1.7 × 10⁻³⁹ |

Entity variance 1.159 (SD 1.077); intraclass correlation **0.261**.

Three findings.

**Solar is the most withdrawal-prone technology in the western queue.** Every
other group carries lower odds of withdrawal, from wind and storage at roughly
half solar's odds to gas and the miscellaneous group at about a third. The
coefficients are stable to every alternative specification: the fixed-effects
fit reproduces them to within 0.01, and dropping suspended and unknown statuses
changes nothing material.

**Larger projects are more likely to be withdrawn**, at 1.13 times the odds per
unit of log capacity — roughly 9% higher odds per doubling of nameplate
capacity. This strengthens to 1.18 under the equal-exposure restriction.

**About a quarter of the latent variation in withdrawal risk sits between
providers.** The intraclass correlation of 0.261 says that a project's odds of
withdrawal depend substantially on whose queue it is in, after accounting for
what kind of project it is, how big it is and when it entered. The provider
random effect has a standard deviation of 1.077 on the log-odds scale,
comparable to the largest technology contrast in the table — the miscellaneous
group, at 1.158 — and larger than every other.

That last result matters for the paper's main question. It establishes that
providers differ materially in queue outcomes even conditional on observable
project attributes. It does not establish that they differ in withdrawal
*timing* — the two are distinct, and timing is what the published median
measures. But it removes any comfortable presumption that providers are
interchangeable once technology and cohort are controlled for, which is exactly
the presumption the compositional correction in Section 5 has to make.

### 6.3 The cohort coefficients are exposure, not behaviour

The declining odds across cohorts should not be read as a falling propensity to
withdraw. They are dominated by exposure time.

| Cohort | Requests | Withdrawn | Rate | Median years of exposure |
|---|---:|---:|---:|---:|
| ≤2014 | 2,752 | 2,084 | 75.7% | 17 |
| 2015–18 | 1,457 | 1,060 | 72.8% | 9 |
| 2019–21 | 1,263 | 770 | 61.0% | 6 |
| 2022+ | 2,519 | 1,353 | 53.7% | 3 |

A request filed in 2024 has had two years in which to be withdrawn; one filed in
2010 has had fifteen. Restricting to cohorts with at least four years of
exposure attenuates the cohort coefficients (2019–21 moves from 0.446 to 0.539)
without touching the technology or capacity results, which is what one would
expect if the cohort gradient is largely an artefact of the observation window
and the others are not. The substantive findings survive; the cohort gradient
should be read as censoring.

### 6.4 What carries the prediction

| Model | AIC |
|---|---:|
| project attributes only | 9,752.1 |
| entity only | 9,816.8 |
| both | 9,378.6 |

Neither project attributes nor provider identity subsumes the other; both
contribute (likelihood-ratio χ² = 456.2 on 9 df for adding attributes to an
entity-only model). In-sample accuracy at a 0.5 threshold is 71.1% against a
65.9% base rate — a modest improvement, consistent with the general picture that
recorded attributes explain a limited share of queue outcomes.

## 7. Limitations

**The provider process channel is unmeasured and unmeasurable here.** This is
the binding limitation. Section 5 corrects for differences in *what kind of
projects* the reporting providers handle. It cannot correct for differences in
*how* they handle them. If PacifiCorp's withdrawal process is systematically
slower or faster than PSCo's for reasons not encoded in technology, capacity,
cohort or service type, that difference is invisible in this file, because
PacifiCorp's withdrawal dates do not exist. The Section 6 finding that 26% of
latent withdrawal-risk variation is between providers makes this channel a live
concern rather than a formality, and it is entirely plausible that it is larger
than the compositional channel measured here. Establishing that would require
withdrawal dates from at least one large non-reporting provider — obtainable, in
principle, from FERC Form 715 filings or direct queue archives, but not from
this data file.

**The calibration assumes transportability.** Stage A estimates how technology
and cohort shift duration in CAISO, ISO-NE, MISO and PJM, and Section 5.2's
validation is conducted within those same regions. Applying those effects to the
West assumes the relationships carry over. Western interconnection processes
differ from ISO tariff processes in ways that could plausibly alter them. This
assumption is load-bearing only for the model-assisted transport estimator,
which the validation already disqualifies; the preferred post-stratification
estimator uses the ISO regions solely to establish that technology and cohort
matter enough to be worth stratifying on, and takes its cell values from western
data.

**Right-truncation is bounded, not eliminated.** Section 5.4 sets out the
problem and the matched window addresses it, but capping at four years and
discarding post-2021 cohorts is a blunt instrument. A survival-analytic
treatment — modelling time to withdrawal with censoring for requests still
active — would use the data more efficiently. It was not attempted here because
the censoring pattern is itself entangled with the reporting problem: for
non-reporting providers we know a request was withdrawn but not when, which is
neither a standard observation nor a standard censoring event.

**Thin cells.** Eight of 24 standardisation cells hold fewer than five dated
records, carrying 5.3% of the target weight; two hold none, carrying 0.08%. The
bootstrap intervals reflect this, but a median computed from three observations
is a fragile input regardless of how its uncertainty is propagated.

**Technology and cohort groupings are choices.** Six technology groups and four
cohort bins were fixed before estimation on the criteria stated in Section 2 —
each cohort carrying at least 14% of target weight, 2019–21 isolated as the
surge, 2022+ isolated as the truncation-dominated bin — but finer or coarser
schemes would give somewhat different numbers. Given the validation result, no
plausible alternative stratification would change the magnitude conclusion.

**The outcome coding in Section 6 is a judgement.** Suspended (244 requests) and
unknown (10) are treated as not withdrawn. Dropping them entirely leaves the
coefficients essentially unchanged, so the choice is not consequential, but it
is a choice.

**One data source, one vintage.** Everything rests on the 2026 Edition file.
Reporting practice changes; several providers that record nothing today may
begin to, and the composition of the reporting subset would change with them.

## 8. Conclusion

The published median withdrawal duration for the non-ISO West rests on 12.1% of
the region's withdrawals, filed with five or six of its thirty-one transmission
providers, in service territories covering a minority of the region's queue. The
largest western provider, PacifiCorp, contributes 31% of the region's
withdrawals and 6% of its recorded withdrawal dates.

That reporting subset is measurably unlike the region it represents. Its
technology mix, queue cohort distribution and interconnection service type all
differ at p < 10⁻¹¹; only project capacity does not.

Yet standardising the subset to the region's actual composition moves the median
by less than three months on any specification, and by about three weeks on the
one that matches the published estimand — with an interval that includes zero
and a sign that reverses under a truncation-matched window. A validation
exercise inside the well-covered ISO regions explains why: imposing the West's
compositional distortion on a population whose durations are fully observed
shifts the median by roughly eight days. Technology, cohort and capacity account
for under 5% of the variance in withdrawal duration, so a composition gap, even
a large and highly significant one, has little room to move a median.

The practical conclusion is not that the published figure is wrong. It is that
the caveat usually attached to such figures — that the reporting subset might
have an unrepresentative project mix — is the wrong caveat, or at least the
minor one. The composition problem is real, statistically unambiguous, and small
in effect. The problem that remains is coverage itself: a statistic drawn from
one eighth of the population, concentrated in five providers, whose principal
risk is that those five may run their queues on a different clock from the
twenty-six that publish nothing. That risk cannot be quantified from this data
file, and the finding that a quarter of the latent variation in withdrawal risk
sits between providers suggests it should not be assumed away.

The most useful thing that could be done with this result is not a better
correction. It is a withdrawal date from BPA, Idaho Power, APS, NorthWestern,
NV Energy, WAPA or PacifiCorp.

---

## Reproducing

Requires R (tested on 4.6.1) with `readxl`, `dplyr`, `tidyr`, `ggplot2` and
`lme4`. Open `queue-analysis.Rproj` and run in order:

| Script | Produces |
|---|---|
| `00-setup.R` | shared definitions; sourced by everything below |
| `01-explore.R` | the original exploratory session, kept as a record |
| `02-figures.R` | `figures/01`–`03` |
| `03-differences.R` | Tables 2, 3; `results/roster.csv`, `differences.csv`, `descriptives.csv` |
| `04-standardise.R` | Tables 1, 4, 5, 6; `results/coverage.csv`, `iso_calibration.csv`, `validation.csv`, `bias_estimate.csv`, `cells.csv` |
| `05-logistic.R` | Table 7; `results/logistic.csv`, `logistic_fit.csv` |
| `06-figures.R` | `figures/04`–`05` |

`04-standardise.R` runs 2,000 bootstrap replicates for each of eight estimates
and takes several minutes. Both it and `05-logistic.R` set a seed
(`20260906`), so results are exactly reproducible.

## Data and licence

`data/LBNL_Ix_Queue_Data_File_thru2025.xlsx`, *Queued Up* 2026 Edition, from
<https://emp.lbl.gov/queues>. Licensed CC BY 4.0; attribution to Lawrence
Berkeley National Laboratory and GridTracker. The analysis code in this
repository is offered under the same terms.

This paper describes the data file as published and takes no position on the
methodology of *Queued Up* itself, whose authors report what transmission
providers disclose and are explicit that coverage varies by region.
