# Western Queue Reporting

<!-- DOI-BADGE -->

Are the interconnection withdrawal dates published for the non-ISO West
representative of the region?

Berkeley Lab's *Queued Up* reports a median duration from interconnection
request to withdrawal for the West. That figure rests on the 12.1% of western
withdrawals that carry a recorded withdrawal date. Of the 31 western
transmission providers with withdrawals in the file, **six record any
withdrawal date and five record one for more than a quarter of their
withdrawals**; the rest — including BPA, Idaho Power, APS, NorthWestern,
NV Energy and WAPA — record none at all. PacifiCorp, whose 1,627 withdrawals
are 2.7 times those of the next-largest western provider, records a date for
6.0% of them — which is why the count reads six or five depending on where the
line is drawn.

This repository tests whether the reporting subset resembles the region it is
used to represent, and estimates how far the published median is displaced as a
result.

## What it finds

**The reporting subset is compositionally unlike the region.** Technology mix,
queue cohort and interconnection service type all differ from the regional
population at p < 10⁻¹¹ after Holm correction, on both defensible definitions
of "the reporting subset." Project capacity does not differ. The dated records
over-represent stand-alone solar (44.8% against 31.5%) and wind (30.7% against
23.1%), and under-represent solar-plus-storage and stand-alone storage.

**But that barely moves the median.** Standardising to the region's actual
technology-by-cohort composition shifts the median from 1.83 to 1.77 years — a
shift of −0.06 years, 95% CI [−0.23, +0.00]. Under a truncation-matched window
the shift is +0.19 years. The sign flips, so the direction of the bias is not
identified. A validation exercise inside the well-covered ISO regions explains
why: imposing the West's compositional distortion on a population whose
durations are fully observed shifts the median by about eight days. Technology,
cohort and capacity together explain 4.6% of the variance in withdrawal
duration.

**The binding caveat is coverage, not composition.** A logistic regression over
all 8,097 western requests — which needs no dates — finds solar the most
withdrawal-prone technology, larger projects more likely to be withdrawn, and
26% of the latent variation in withdrawal risk sitting between providers rather
than between projects. Whether the five reporting providers withdraw on a
different *schedule* from the twenty-six that publish nothing cannot be
determined from this data file, and that, not project mix, is the open question.

The full write-up is in [`PAPER.md`](PAPER.md).

## Data

`data/LBNL_Ix_Queue_Data_File_thru2025.xlsx` — the Queued Up 2026 Edition data
file, covering interconnection requests through the end of 2025. Sheet
`03. Complete Queue Data` holds the project-level records.

Source: <https://emp.lbl.gov/queues>

The Queued Up data file is licensed CC BY 4.0. Attribution: Lawrence Berkeley
National Laboratory and GridTracker.

## Reproducing

Requires R (tested on 4.6.1) with `readxl`, `dplyr`, `tidyr`, `ggplot2` and
`lme4`. Open `queue-analysis.Rproj` in RStudio and run the scripts in order.

| Script | Produces |
|---|---|
| `00-setup.R` | shared definitions; sourced by everything below |
| `01-explore.R` | the original exploratory session, kept as a record |
| `02-figures.R` | `figures/01`–`03` |
| `03-differences.R` | the roster and the five comparisons |
| `04-standardise.R` | the ISO calibration, validation and bias estimate |
| `05-logistic.R` | the withdrawal model |
| `06-figures.R` | `figures/04`–`05` |

`04-standardise.R` runs 2,000 bootstrap replicates for each of eight estimates
and takes several minutes. It and `05-logistic.R` set a seed (`20260906`), so
results are exactly reproducible. Result tables are written to `results/`.

## Citing

See [`CITATION.cff`](CITATION.cff).

## Licence

Analysis code and write-up: CC BY 4.0, matching the licence of the underlying
data file.
