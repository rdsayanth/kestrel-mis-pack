# Monthly Operations & Fulfilment MIS Pack — Requirements Note

**Project:** Kestrel Sports Supply — Monthly MIS Pack
**Prepared by:** Sayanth Rajani Divakaran
**Version:** 1.0
**Status:** Delivered. Section 7 shows the status of each requirement.

> **Context:** Kestrel Sports Supply is a **simulated** business, created to frame this project as a commercial reporting engagement. The data comes from the public [DataCo Smart Supply Chain dataset](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) (Constante, Silva & Pereira, Mendeley Data, DOI 10.17632/8gx2fvg2k6). The author constructed the stakeholders, background, targets and recommendations to reflect how this work would be scoped in a real business. Kestrel is not a real company and not an employer.

---

## 1. Background

Kestrel Sports Supply sells sporting goods, apparel and fitness equipment, and ships orders through four shipping modes: Same Day, First Class, Second Class and Standard Class. At the start of each month, the order system exports the previous month's order lines as a CSV file, together with a control file of row counts and totals.

The monthly management pack is currently assembled by hand, which causes three problems:

- **It takes too long.** An analyst pastes the export into Excel, rebuilds pivot tables and copies figures into a summary. This takes most of a working day.
- **Nobody checks the data.** Figures are never reconciled to the system's control totals, so a truncated or duplicated export would go unnoticed.
- **Problems are found late.** Delivery problems and loss-making products only come to light when someone happens to look for them.

The Head of Operations and the Commercial Manager have asked for a pack that meets four needs:

- It refreshes from the export files with no manual pasting.
- It proves that it reconciles to the source.
- It reports a standard set of KPIs against targets.
- It lists the items that need a decision this month.

## 2. Stakeholders

| Role | Interest |
|---|---|
| Head of Operations | Delivery performance by shipping mode, late orders, cancellations |
| Commercial Manager | Net sales, margin, department and category performance, loss-making products |
| Finance Business Partner | Confidence that the figures reconcile to the order system |
| Report owner (analyst) | A refresh that takes minutes and is documented well enough to hand over |

## 3. Business questions

1. Are we on track against target this month, and how do we compare with last month and the same month last year?
2. Are we delivering on the lead times we promise, and if not, which shipping modes and customer segments are failing?
3. Which departments and categories are driving sales and margin?
4. Which products are losing money, and which categories are below the margin floor?
5. Can the pack be trusted? Does it reconcile to the order system's control totals?

## 4. Requirements

| ID | Requirement | Priority |
|---|---|---|
| R1 | The pack refreshes from the monthly export files with one action (Refresh All). No copying or pasting of data. | Must |
| R2 | Every load reconciles to the control file: row counts, order counts, gross and net sales, by month and in total. | Must |
| R3 | A one-page summary shows the headline KPIs for any chosen month, against the prior month, the same month last year and target, with a status flag. | Must |
| R4 | Delivery performance is broken down by shipping mode and by mode × customer segment. | Must |
| R5 | Commercial performance is broken down by department, top categories and customer segment. | Must |
| R6 | An exception report lists loss-making products, late-rate breaches and categories below the margin floor, worst first. | Must |
| R7 | Targets and exception thresholds are inputs that can be changed without editing formulas. | Must |
| R8 | Excel only (Microsoft 365, Power Query). No BI licence, database or scripting is needed to run it. | Must |
| R9 | KPI definitions, data quality decisions and the refresh procedure are documented. | Must |
| R10 | The summary prints on one A4 page. | Should |
| R11 | A 13-month trend is shown for the main KPIs. | Should |

## 5. Out of scope

- **Geographic (market/region) reporting.** The source data assigns markets in rotating blocks of months, so market comparisons would be misleading. See DQ-03.
- **Order months from October 2017 onwards.** The source data changes structure at that point. See DQ-01.
- Forecasting, customer-level analysis and customer lifetime value.
- Automated distribution of the pack. It is exported to PDF manually.

## 6. Data

| Item | Detail |
|---|---|
| Source | DataCo Smart Supply Chain (`DataCoSupplyChainDataset.csv`, 180,519 order lines, 53 columns) |
| Feed simulated as | One `extract_YYYY-MM.csv` plus one `control_YYYY-MM.csv` per order month (`scripts/make_monthly_extracts.py`) |
| Reporting window | January 2015 – September 2017 (33 months, 171,962 order lines, 57,349 orders) |
| Initial load | January 2015 – August 2017 (32 months) |
| Refresh demonstration | September 2017, held back in `incoming/` |
| Grain in the pack | Orders (one row per order) and product-month (one row per product per month) |

## 7. Status against requirements

| ID | Status | Where |
|---|---|---|
| R1 | Met | Power Query reads every file in `monthly_extracts/` (From Folder). See `docs/04_refresh_procedure.md`. |
| R2 | Met | Checks sheet: 18 checks, including 6 reconciliations to control totals |
| R3 | Met | Summary sheet; the month is chosen on the Control sheet |
| R4 | Met | Fulfilment sheet, sections 2–3 |
| R5 | Met | Commercial sheet, sections 1–3 |
| R6 | Met | Exceptions sheet, sections A–C |
| R7 | Met | Control sheet; inputs are blue text on yellow cells |
| R8 | Met | Excel + Power Query only. Python is used once, to *simulate* the export feed. |
| R9 | Met | `docs/02_kpi_definitions.md`, `docs/03_data_quality_log.md`, `docs/04_refresh_procedure.md` |
| R10 | Met | The Summary print area is set to fit one A4 landscape page |
| R11 | Met | 13-month trend on Summary, Fulfilment and Commercial |
