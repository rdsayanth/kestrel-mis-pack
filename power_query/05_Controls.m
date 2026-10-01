// Controls  (one row per loaded month: the source system's control totals)  ->  load to sheet Data_Controls, cell A1
// The Checks sheet reconciles the loaded data against these totals.
let
    Source = Folder.Files(pExtractFolder),
    ControlFiles = Table.SelectRows(Source, each Text.StartsWith([Name], "control_") and Text.Lower([Extension]) = ".csv"),
    ParsedFiles = Table.AddColumn(ControlFiles, "Rows", each
        Table.PromoteHeaders(
            Csv.Document([Content], [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            [PromoteAllScalars = true])),
    Combined = Table.Combine(ParsedFiles[Rows]),
    Typed = Table.TransformColumnTypes(Combined, {
        {"period", type text}, {"extract_file", type text},
        {"row_count", Int64.Type}, {"order_count", Int64.Type},
        {"gross_sales", type number}, {"net_sales", type number},
        {"generated_at", type datetime}}, "en-US"),
    AddMonthStart = Table.AddColumn(Typed, "MonthStart", each
        #date(Number.FromText(Text.Start([period], 4)), Number.FromText(Text.End([period], 2)), 1), type date),
    Renamed = Table.RenameColumns(AddMonthStart, {
        {"period", "Period"}, {"extract_file", "ExtractFile"}, {"row_count", "RowCount"},
        {"order_count", "OrderCount"}, {"gross_sales", "GrossSales"}, {"net_sales", "NetSales"},
        {"generated_at", "GeneratedAt"}}),
    Ordered = Table.SelectColumns(Renamed, {
        "Period", "MonthStart", "ExtractFile", "RowCount", "OrderCount", "GrossSales", "NetSales", "GeneratedAt"}),
    Sorted = Table.Sort(Ordered, {{"Period", Order.Ascending}})
in
    Sorted
