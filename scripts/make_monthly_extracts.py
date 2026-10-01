"""
make_monthly_extracts.py
------------------------
Simulates the monthly order-system export feed for the Kestrel Sports Supply MIS pack.

Reads the public DataCo Smart Supply Chain file and writes, for every month in the
reporting window, one extract file plus one control file:

    extract_YYYY-MM.csv   order-line rows for that order month (source column names kept)
    control_YYYY-MM.csv   control totals the receiving workbook reconciles against

Window and routing (see docs/03_data_quality_log.md):
    Jan 2015 - Aug 2017  -> monthly_extracts/   (initial load)
    Sep 2017             -> incoming/           (held back to demonstrate the monthly refresh)
    Oct 2017 - Jan 2018  -> not exported        (structural break, see DQ-01)

Usage:
    python scripts/make_monthly_extracts.py path/to/DataCoSupplyChainDataset.csv
"""
import sys
from pathlib import Path

import pandas as pd

SOURCE_ENCODING = "cp1252"          # the Kaggle file is Windows-1252, not UTF-8
WINDOW_START = "2015-01-01"
WINDOW_END = "2017-10-01"           # exclusive
HELD_BACK_MONTH = "2017-09"         # written to incoming/ for the refresh demo

# Columns kept in the export. Dropped: customer name/email/password/street/zip,
# store lat/long, product image URL, Product Description (100% blank), Order Zipcode
# (86% blank) and fields that duplicate others exactly (see DQ log).
KEEP = [
    "Order Id", "Order Item Id", "order date (DateOrders)", "shipping date (DateOrders)",
    "Type", "Order Status", "Delivery Status", "Late_delivery_risk", "Shipping Mode",
    "Days for shipping (real)", "Days for shipment (scheduled)",
    "Order Customer Id", "Customer Segment", "Market", "Order Region",
    "Department Name", "Category Name", "Product Card Id", "Product Name",
    "Order Item Product Price", "Order Item Quantity", "Sales",
    "Order Item Discount", "Order Item Discount Rate", "Order Item Total",
    "Order Profit Per Order",
]


def main(src: str) -> None:
    root = Path(__file__).resolve().parents[1]
    out_main = root / "monthly_extracts"
    out_incoming = root / "incoming"
    out_main.mkdir(exist_ok=True)
    out_incoming.mkdir(exist_ok=True)

    # Read everything as text so the extract files carry the source values unchanged
    raw = pd.read_csv(src, encoding=SOURCE_ENCODING, dtype=str, keep_default_na=False)[KEEP]
    order_dt = pd.to_datetime(raw["order date (DateOrders)"], format="%m/%d/%Y %H:%M")
    raw["_period"] = order_dt.dt.strftime("%Y-%m")

    in_window = (order_dt >= WINDOW_START) & (order_dt < WINDOW_END)
    excluded = raw.loc[~in_window, "_period"].value_counts().sort_index()
    data = raw.loc[in_window]

    for period, block in data.groupby("_period", sort=True):
        target = out_incoming if period == HELD_BACK_MONTH else out_main
        block = block.drop(columns="_period").sort_values(
            ["Order Id", "Order Item Id"], key=lambda s: s.astype(int))
        extract_name = f"extract_{period}.csv"
        block.to_csv(target / extract_name, index=False, encoding="utf-8")

        y, m = map(int, period.split("-"))
        generated = pd.Timestamp(year=y, month=m, day=1) + pd.offsets.MonthBegin(1)
        control = pd.DataFrame([{
            "period": period,
            "extract_file": extract_name,
            "row_count": len(block),
            "order_count": block["Order Id"].nunique(),
            "gross_sales": round(block["Sales"].astype(float).sum(), 2),
            "net_sales": round(block["Order Item Total"].astype(float).sum(), 2),
            "generated_at": generated.strftime("%Y-%m-%d") + " 06:00",
        }])
        control.to_csv(target / f"control_{period}.csv", index=False, encoding="utf-8")
        print(f"{period}: {len(block):>6} lines -> {target.name}/")

    print("\nNot exported (outside reporting window):")
    print(excluded.to_string())


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "DataCoSupplyChainDataset.csv")
