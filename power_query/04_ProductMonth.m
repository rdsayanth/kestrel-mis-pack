// ProductMonth  (one row per month x product, valid order lines only)  ->  load to sheet Data_ProductMonth, cell A1
let
    Source = stg_Lines,
    ValidLines = Table.SelectRows(Source, each [IsCancelled] = 0),
    Grouped = Table.Group(ValidLines, {"MonthStart", "Period", "Department", "Category", "Product"}, {
        {"Lines", each Table.RowCount(_), Int64.Type},
        {"Units", each List.Sum([Quantity]), Int64.Type},
        {"GrossSales", each List.Sum([GrossSales]), type number},
        {"Discount", each List.Sum([Discount]), type number},
        {"NetSales", each List.Sum([NetSales]), type number},
        {"Profit", each List.Sum([Profit]), type number}}),
    Sorted = Table.Sort(Grouped, {
        {"MonthStart", Order.Ascending}, {"Department", Order.Ascending},
        {"Category", Order.Ascending}, {"Product", Order.Ascending}})
in
    Sorted
