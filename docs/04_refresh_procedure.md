# Refresh Procedure

**Project:** Kestrel Sports Supply — Monthly MIS Pack (simulated business, public DataCo dataset)
**Version:** 1.0
**Requires:** Microsoft 365 Excel for Windows (Power Query is built in)

This document has three parts:
- **Part A:** one-time set-up of the Power Query connections.
- **Part B:** the monthly refresh, about 5 minutes each month.
- **Part C:** what to do when a check fails.

Part D walks through the September 2017 load used to demonstrate the process.

---

## Part A — One-time set-up (about 15 minutes)

The workbook comes with the January 2015 – August 2017 data already loaded, so it works when you open it. Part A replaces that static copy with live Power Query connections to the `monthly_extracts` folder. The query code is in `power_query/`.

**A1. Check the folder path.** Open `power_query/01_pExtractFolder.m` and confirm that the path matches where `monthly_extracts` is on your PC. If you cloned the repo somewhere else, edit the path.

**A2. Create the five queries.** In Excel, go to **Data → Get Data → Launch Power Query Editor**. Then, for each file in this order:

| Order | File | Query name (exact) |
|---|---|---|
| 1 | `01_pExtractFolder.m` | `pExtractFolder` |
| 2 | `02_stg_Lines.m` | `stg_Lines` |
| 3 | `03_Orders.m` | `Orders` |
| 4 | `04_ProductMonth.m` | `ProductMonth` |
| 5 | `05_Controls.m` | `Controls` |

1. **Home → New Source → Other Sources → Blank Query.**
2. **Home → Advanced Editor**, select everything, paste the contents of the `.m` file, then click **Done**.
3. In the **Query Settings** pane on the right, rename the query to the exact name in the table.

The names matter, because the later queries refer to the earlier ones by name. `pExtractFolder` will show as a parameter (it has a different icon). Click `Orders` and check that it shows about 55,600 rows. If it shows an error, check the path in step A1.

**A3. Load everything as connections first.** **Home → Close & Load ▾ → Close & Load To… → Only Create Connection → OK.**

**A4. Clear the static data.** For each of the sheets `Data_Orders`, `Data_ProductMonth` and `Data_Controls`:
1. Click cell A1.
2. Press **Ctrl+A** (twice if needed) to select the whole sheet.
3. Press **Delete**.

> Only clear the contents. Do **not** delete the sheets or any columns. The report formulas point at these sheets through named ranges, and those survive a clear but not a delete. The report sheets will show zeros or `n/a` until step A5 is done.

**A5. Load the three output queries onto those sheets.** Open **Data → Queries & Connections**. For each query below, right-click it → **Load To… → Table → Existing worksheet** → type the cell → **OK**.

| Query | Load to |
|---|---|
| `Orders` | `=Data_Orders!$A$1` |
| `ProductMonth` | `=Data_ProductMonth!$A$1` |
| `Controls` | `=Data_Controls!$A$1` |

Leave `pExtractFolder` and `stg_Lines` as connection only.

**A6. Verify against the expected figures.** Go to **Control**, set the month to **2017-08**, then compare:

| Where | Expected |
|---|---|
| Checks → Overall status | **ALL 18 CHECKS PASS** |
| Summary → Net sales (Actual) | **$958,772** |
| Summary → Gross margin % | **13.2%** |
| Summary → Valid orders | **1,695** |
| Summary → On-time delivery % | **42.1%** |
| Summary → Cancellation rate % | **4.1%** |
| Exceptions → Products with a loss | **2** |

If they match, Power Query is producing exactly what the pack was built and tested on. **Save the workbook.**

---

## Part B — Monthly refresh (about 5 minutes)

| Step | Action | Check |
|---|---|---|
| B1 | Receive `extract_YYYY-MM.csv` and `control_YYYY-MM.csv` from the order system. | Both files are present for the same month. |
| B2 | Copy both files into `monthly_extracts/`. Don't rename them. | – |
| B3 | Open the workbook → **Data → Refresh All**. Wait until the status bar is clear. | – |
| B4 | **Control** → pick the new month from the drop-down. | The month appears in the list. If it doesn't, the control file was not picked up. |
| B5 | **Checks** → Overall status. | **ALL 18 CHECKS PASS.** If not, see Part C. **Do not send the pack while any check fails.** |
| B6 | Read **Summary**, then **Exceptions**. Write the month's commentary (see `05_findings_memo_2017-09.md` for the format). | – |
| B7 | **File → Export → PDF** of the Summary, Fulfilment, Commercial and Exceptions sheets. Save the workbook. | The Summary fits one page. |

---

## Part C — When a check fails

| Check(s) | Usually means | Action |
|---|---|---|
| 1, 2, 7 | An extract was copied without its control file, or the other way round | Copy the missing file, then Refresh All |
| 3, 4, 8, 9 | The extract is truncated or contains duplicates | Ask for the export to be re-run. Don't report the month. |
| 5, 6, 10 | Totals don't match the source system | As above. A difference of a few cents is within tolerance. |
| 11 | The product table and order table disagree | A Power Query step has changed. Compare against `power_query/`. |
| 12 – 15 | A **new** department, category, shipping mode or segment has appeared | Find the new value (filter the Data sheet). Add it to the **Lists** sheet (yellow cells). The check turns PASS. Note it in the data quality log. |
| 16 | A month is missing between the first and last month loaded | Find and load the missing month's files |
| 17, 18 | The source has blank or unexpected status values | Investigate the extract before reporting |

---

## Part D — Demonstration: loading September 2017

> **Status:** this load has been completed. The September files now sit in `monthly_extracts/`, and the workbook is loaded to September 2017. To repeat the demonstration, move the two 2017-09 files into a folder named `incoming/`, remove "Basketball" from the Lists sheet, then Refresh All and follow the steps below.

The September 2017 files were held back in `incoming/` at first, so the monthly refresh could be demonstrated.

1. Move `incoming/extract_2017-09.csv` and `incoming/control_2017-09.csv` into `monthly_extracts/`.
2. **Data → Refresh All**. Then go to **Control** and select **2017-09**.
3. **Checks** shows **1 CHECK(S) FAILED**: check 13, *Category list covers all product net sales*, with a difference of **−$16,234.94**. This is expected.
4. Find the cause: in `Data_ProductMonth`, filter Period = 2017-09. The category **Basketball** is not on the Lists sheet. It is new this month, and it holds two children's hybrid bikes and an elliptical trainer (logged as DQ-14).
5. Type `Basketball` into the first yellow cell under **Category** on the Lists sheet. Check 13 turns PASS, and the overall status reads **ALL 18 CHECKS PASS**.
6. Expected September figures: net sales **$976,908**, gross margin **12.1%**, valid orders **1,640**, on-time **42.6%**, cancellation **4.8%**, 8 loss-making products. The findings memo for this month is `docs/05_findings_memo_2017-09.md`.
