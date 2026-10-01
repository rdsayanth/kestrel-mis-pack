# Data Quality Log

**Project:** Kestrel Sports Supply — Monthly MIS Pack (simulated business, public DataCo dataset)
**Version:** 1.0
**Source profiled:** `DataCoSupplyChainDataset.csv`: 180,519 rows × 53 columns, order dates 1 Jan 2015 – 31 Jan 2018

Every issue found during profiling is listed below with the decision taken and where it is handled.

| ID | Issue | Evidence | Decision | Handled in |
|---|---|---|---|---|
| DQ-01 | **Structural break from October 2017.** From that month the product range shrinks, products never sold before appear, and every order becomes single-line. | Products sold per month: 53 (Sep 2017) → 20, 8, 14, 10 (Oct 2017 – Jan 2018). 18 of the products sold in Oct 2017 – Jan 2018 never appear earlier. Lines per order fall from about 3.0 to about 1.0 (Oct: 2,255 lines / 2,101 orders; Nov – Jan: lines = orders). Net sales (all orders) hold at $0.97m in October, then fall to $0.56m, $0.45m and $0.30m in Nov – Jan, against about $1.0m a month in 2017. | Exclude Oct 2017 – Jan 2018 (8,557 lines). These months do not represent the same business, and including them would show a false collapse in sales. | `make_monthly_extracts.py` (not exported) |
| DQ-02 | **The file is at order-line grain, not order grain.** | 180,519 rows; 65,752 distinct Order Ids. In every order, all lines share the same order date, status, delivery status, shipping mode, segment and shipping days (0 conflicts). | Delivery KPIs are counted per **order** (an order with 3 lines is one delivery). Sales and profit are summed from lines. | Power Query `Orders` (Group By OrderId) |
| DQ-03 | **Market and Order Region rotate in blocks of months.** | Jan – Apr 2015 contain only LATAM; Jun – Sep 2015 only Europe; Nov 2015 – Mar 2016 only Pacific Asia; May – Jul 2016 only USCA. In the full file, 975 of 1,127 order days contain a single market. | Market is **not** used as a reporting dimension, because a month-on-month or year-on-year market comparison would mostly reflect the rotation, not performance. The field is kept on `Data_Orders` for traceability. | Report design |
| DQ-04 | **Dates are US-format text** (`1/31/2018 22:56`). | On a PC with Irish or UK regional settings, a default type conversion reads 1/3/2015 as 1 March. | Types are converted with the `"en-US"` culture in Power Query, so the result does not depend on the PC's locale. | `stg_Lines` step `Typed` |
| DQ-05 | **Trailing spaces in text fields** (e.g. `"Smart watch "`, `"Health and Beauty "`). | Found only in the excluded Oct 2017 – Jan 2018 rows; none in the reporting window. | Text.Trim is kept on all text columns as a defensive step, so a future extract cannot split one product into two. | `stg_Lines` step `Trimmed` |
| DQ-06 | **"Order Profit Per Order" is a line-level value, despite its name.** | The value differs between lines of the same order in all 45,902 multi-line orders. "Benefit per order" holds identical values. "Sales per customer" is identical to "Order Item Total". | Treated as **line gross profit** and summed to order and product level. The duplicate columns are dropped from the extract. | Extract column list; `stg_Lines` rename to `Profit` |
| DQ-07 | **Defining a cancelled order.** | Delivery status `Shipping canceled` (7,754 lines in the full file) = Order Status CANCELED (3,692) + SUSPECTED_FRAUD (4,062), exactly. | Cancelled = delivery status `Shipping canceled`. These orders are excluded from commercial and delivery KPIs and counted in the cancellation rate. Fraud is also reported separately. | `stg_Lines` `IsCancelled`; `Orders` `IsFraud` |
| DQ-08 | **Three overlapping "late" fields.** | `Delivery Status = Late delivery`, `Late_delivery_risk = 1` and `actual days > scheduled days` agree on every non-cancelled row in the window. | Late is derived from the days (`ActualDays > ScheduledDays`), because that rule is transparent and can be audited. The flag is not relied on. | `Orders` `IsLate` |
| DQ-09 | **Shipping days follow fixed patterns by mode.** | First Class: promised 1 day, actual is 2 days on **every** order (8,369 in the window). Same Day: promised 0, actual 0 or 1. Second and Standard Class: actual spread evenly over 2 – 6 days (average 4.0 for both), while Second Class promises 2 and Standard promises 4. | Reported as found. These patterns drive the delivery findings, and the findings memo flags that because the dataset is synthetic, the patterns limit how far causes can be inferred. | Findings memo §2 |
| DQ-10 | **"Days for shipping (real)" counts calendar days, not elapsed time.** | 4,657 lines (all Same Day) show 1 day where the order and ship timestamps are less than 24 hours apart. In every case the ship timestamp falls on the next calendar date (e.g. ordered 23:00, shipped 01:00). | The source's day counts are used as the measure of record. | `stg_Lines` |
| DQ-11 | **Empty and personal columns.** | Product Description 100% blank; Order Zipcode 86% blank; Customer Lname 8 blanks; Customer Zipcode 3 blanks. Customer email, password (masked), names and street are present. | Dropped from the extract (not needed for the pack, and personal data stays out of the repo). | Extract column list |
| DQ-12 | **The source file is Windows-1252, not UTF-8.** | e.g. `México` in Order Country is garbled when the file is read as UTF-8. | The source is read as cp1252, and the extracts are written as UTF-8. Power Query reads them with `Encoding = 65001`. | Extract script; `stg_Lines` |
| DQ-13 | **Loss-making lines are common, and discounting does not explain them.** | 18.7% of valid lines have negative profit (profit ratio as low as −275%). The average profit ratio is about 12% in every discount band (0 – 5%, 5 – 10% … 20 – 25%). | Profit is taken as given. Loss-making products are surfaced in the Exceptions report rather than "corrected". | Exceptions §A; findings memo §4 |
| DQ-14 | **New category on the September 2017 load: "Basketball".** | Check 13 failed after the refresh (difference −$16,234.94). The category holds two children's hybrid bikes and an elliptical trainer, which looks like a product-to-category mapping error in the source. | Added "Basketball" to the Lists sheet so the reconciliation passes. The mapping is logged for the product-master owner to review, and the category's figures are reported as supplied. | Lists sheet; findings memo §5 |
| DQ-15 | **Rounding in control totals.** | Control totals are rounded to 2 dp; source values are float32 artefacts (e.g. `314.6400146`). | Reconciliation tolerance is $1.00 for all-month totals and $0.50 for single-month totals. Row and order counts must match exactly. | Checks sheet |

## Reconciliation summary (after the September 2017 load)

| Measure | Control files | Workbook | Difference |
|---|---|---|---|
| Months | 33 | 33 | 0 |
| Order lines | 171,962 | 171,962 | 0 |
| Orders | 57,349 | 57,349 | 0 |
| Gross sales (USD) | 34,248,265.52 | 34,248,265.53 | 0.01 |
| Net sales (USD) | 30,774,233.91 | 30,774,233.92 | 0.01 |
| Sep 2017 net sales (USD) | 1,027,111.73 | 1,027,111.73 | 0.00 |
