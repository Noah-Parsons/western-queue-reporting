# Western Queue Reporting

Are the interconnection withdrawal dates published for the non-ISO West
representative of the region?

Berkeley Lab's *Queued Up* reports a median duration from interconnection
request to withdrawal for the West region. That figure rests on the six
of 31 western transmission providers that record withdrawal dates; the
other 25 — including BPA, Idaho Power, APS, NorthWestern, NV Energy and
WAPA — report none. This repository tests whether the reporting subset
resembles the region it is used to represent.

## Data

`data/LBNL_Ix_Queue_Data_File_thru2025.xlsx` — the Queued Up 2026 Edition
data file, covering interconnection requests through the end of 2025.
Sheet `03. Complete Queue Data` holds the project-level records.

Source: https://emp.lbl.gov/queues

The Queued Up data file is licensed CC BY 4.0. Attribution: Lawrence
Berkeley National Laboratory and GridTracker.

## Reproducing

Requires R with `readxl` and `dplyr`. Open `queue-analysis.Rproj` in
RStudio and source `01-explore.R`.

## Status

Exploratory analysis. Findings not yet written up.