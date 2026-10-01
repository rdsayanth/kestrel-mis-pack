# KPI Definitions

**Project:** Kestrel Sports Supply — Monthly MIS Pack (simulated business, public DataCo dataset)
**Version:** 1.0

Every KPI in the pack is defined once here, and the workbook calculates it the same way on every sheet. Formulas use the workbook's named ranges. For example, `O_NetSales` is the NetSales column of the Orders table, and it resizes automatically when Power Query reloads.

## 1. Base populations

| Term | Definition | Workbook field |
|---|---|---|
| **Orders placed** | Every order whose order date falls in the month | all rows of `Data_Orders` for the month |
| **Cancelled order** | Delivery status = `Shipping canceled`. This is exactly the set of orders with status CANCELED or SUSPECTED_FRAUD (DQ-07). | `IsCancelled = 1` |
| **Valid order** | An order placed that was not cancelled. All commercial and delivery KPIs use valid orders. | `IsShipped = 1` |
| **Late order** | A valid order whose actual shipping days are greater than the promised (scheduled) days | `IsLate = 1` |
| **Month** | The calendar month of the order date (not the ship date) | `MonthStart` |

Monetary values are in USD, as supplied by the source.

## 2. Headline KPIs (Summary sheet)

| # | KPI | Definition | Formula (selected month = `m`) | Direction | Target |
|---|---|---|---|---|---|
| 1 | Net sales | Sales after discount, valid orders | `SUMIFS(O_NetSales, O_MonthStart, m, O_IsShipped, 1)` | Higher | Same month last year +3% |
| 2 | Gross profit | Profit as supplied by the order system, valid orders | `SUMIFS(O_Profit, …, O_IsShipped, 1)` | Higher | – |
| 3 | Gross margin % | Gross profit ÷ net sales | KPI 2 ÷ KPI 1 | Higher | 12.0% |
| 4 | Valid orders | Count of valid orders | `COUNTIFS(O_MonthStart, m, O_IsShipped, 1)` | – | – |
| 5 | Average order value | Net sales ÷ valid orders | KPI 1 ÷ KPI 4 | – | – |
| 6 | Discount rate | Discount ÷ gross sales (before discount), valid orders | `SUMIFS(O_Discount,…) / SUMIFS(O_GrossSales,…)` | – | – |
| 7 | On-time delivery % | Valid orders delivered within the promised days ÷ valid orders | `1 − COUNTIFS(…, O_IsLate, 1) / KPI 4` | Higher | 50.0% |
| 8 | Average delay on late orders | Mean of (actual − promised days), late orders only | `AVERAGEIFS(O_DelayDays, …, O_IsLate, 1)` | Lower | – |
| 9 | Cancellation rate % | Cancelled orders ÷ orders placed | `COUNTIFS(…, O_IsCancelled, 1) / COUNTIFS(O_MonthStart, m)` | Lower | 4.0% |
| 10 | Suspected fraud rate % | Orders with status SUSPECTED_FRAUD ÷ orders placed | `COUNTIFS(…, O_IsFraud, 1) / orders placed` | Lower | 2.0% |

## 3. Comparisons and status

| Item | Rule |
|---|---|
| Prior month (PM) | The calendar month before the selected month. Shows `n/a` if that month is not loaded. |
| Same month last year (LY) | The selected month minus 12 months. Shows `n/a` if not loaded. |
| Δ for money and count KPIs | Percentage change: actual ÷ comparison − 1 |
| Δ for percentage KPIs | Difference in **percentage points** (pts), e.g. 4.8% vs 4.1% = +0.7 pts |
| Status: higher-is-better KPIs | **On track** if actual ≥ target. **Watch** if within the amber tolerance below target. **Off track** otherwise. |
| Status: lower-is-better KPIs | **On track** if actual ≤ target. **Watch** if within the tolerance above target. **Off track** otherwise. |
| Status: net sales | Judged on growth vs the same month last year (target +3%, tolerance 2 pts) |
| Amber tolerances | Growth 2.0 pts · margin 0.5 pts · on-time 5.0 pts · cancellation 0.5 pts · fraud 0.5 pts |

The targets are illustrative and were set by the report owner. Every target and tolerance is an input on the Control sheet.

## 4. Breakdown measures

| Sheet | Measure | Definition |
|---|---|---|
| Fulfilment | Delivery outcome mix | Orders placed by delivery status (Advance shipping / Shipping on time / Late delivery / Shipping canceled) ÷ orders placed |
| Fulfilment | Mix % by mode | Valid orders in the mode ÷ all valid orders |
| Fulfilment | Promised days | Average scheduled shipping days, valid orders in the mode |
| Fulfilment | Avg actual days | Average actual shipping days, valid orders in the mode |
| Fulfilment | Late % by mode | Late orders in the mode ÷ valid orders in the mode |
| Fulfilment | Late % mode × segment | The same measure, split by customer segment (Consumer / Corporate / Home Office) |
| Commercial | Department and category net sales, profit and margin | From `Data_ProductMonth` (valid order lines aggregated by month and product) |
| Commercial | Share | Department or category net sales ÷ total net sales |
| Commercial | Segment AOV | Segment net sales ÷ segment valid orders |

## 5. Exception rules (Exceptions sheet)

| Section | Rule | Default threshold | Sort |
|---|---|---|---|
| A. Loss-making products | Product gross profit < 0 in the month | fixed at 0 | Largest loss first (top 10 shown, all counted) |
| B. Late-rate breaches | Shipping mode × segment late % above threshold | 60% | Worst first |
| C. Categories below margin floor | Category margin < floor, and category net sales ≥ minimum | 10% floor, $5,000 minimum | Lowest margin first |

Ties are broken by row position, using a helper "sort key" column (value + row ÷ 10⁷), so every item gets a unique rank.

## 6. Data quality checks (Checks sheet)

| # | Check | Pass rule |
|---|---|---|
| 1 | Every loaded control file has order data | Months with orders = control files |
| 2 | No order data without a control file | Orders in control months = all orders |
| 3 | All months: order lines = control row count | Exact |
| 4 | All months: orders = control order count | Exact (detects duplicates) |
| 5 | All months: gross sales = control total | Within $1.00 |
| 6 | All months: net sales = control total | Within $1.00 |
| 7 | Selected month is loaded | Exactly 1 control row |
| 8 | Selected month: order lines = control row count | Exact |
| 9 | Selected month: orders = control order count | Exact |
| 10 | Selected month: net sales = control total | Within $0.50 |
| 11 | Selected month: product table = order table (valid orders) | Within $0.50 |
| 12 | Department list covers all product net sales | Within $1.00 |
| 13 | Category list covers all product net sales | Within $1.00 |
| 14 | Shipping mode list covers all orders | Exact |
| 15 | Segment list covers all orders | Exact |
| 16 | Months are continuous | Months loaded = months between first and last |
| 17 | No blank month, status, mode or segment on orders | 0 blanks |
| 18 | Every order is either valid or cancelled | Valid + cancelled = orders |

The tolerances exist because control totals are rounded to 2 decimal places, while the source values carry floating-point precision.
