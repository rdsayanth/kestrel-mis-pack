// stg_Lines  (connection only - staging query, one row per order line)
// Combines every extract_YYYY-MM.csv in pExtractFolder, cleans and types the columns.
// Load setting: Close & Load To > Only Create Connection.
let
    Source = Folder.Files(pExtractFolder),

    // only the monthly extract files; control files are read by the Controls query
    ExtractFiles = Table.SelectRows(Source, each Text.StartsWith([Name], "extract_") and Text.Lower([Extension]) = ".csv"),

    ParsedFiles = Table.AddColumn(ExtractFiles, "Rows", each
        Table.PromoteHeaders(
            Csv.Document([Content], [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            [PromoteAllScalars = true])),
    Combined = Table.Combine(ParsedFiles[Rows]),

    // source system names -> report names
    Renamed = Table.RenameColumns(Combined, {
        {"Order Id", "OrderId"}, {"Order Item Id", "OrderItemId"},
        {"order date (DateOrders)", "OrderDateTime"}, {"shipping date (DateOrders)", "ShipDateTime"},
        {"Type", "PaymentType"}, {"Order Status", "OrderStatus"}, {"Delivery Status", "DeliveryStatus"},
        {"Late_delivery_risk", "LateRiskFlag"}, {"Shipping Mode", "ShippingMode"},
        {"Days for shipping (real)", "ActualShipDays"}, {"Days for shipment (scheduled)", "ScheduledShipDays"},
        {"Order Customer Id", "CustomerId"}, {"Customer Segment", "Segment"}, {"Order Region", "OrderRegion"},
        {"Department Name", "Department"}, {"Category Name", "Category"},
        {"Product Card Id", "ProductId"}, {"Product Name", "Product"},
        {"Order Item Product Price", "UnitPrice"}, {"Order Item Quantity", "Quantity"}, {"Sales", "GrossSales"},
        {"Order Item Discount", "Discount"}, {"Order Item Discount Rate", "DiscountRate"},
        {"Order Item Total", "NetSales"}, {"Order Profit Per Order", "Profit"}}),

    // DQ-05: several product and department names carry trailing spaces in the source
    Trimmed = Table.TransformColumns(Renamed, {
        {"PaymentType", Text.Trim, type text}, {"OrderStatus", Text.Trim, type text},
        {"DeliveryStatus", Text.Trim, type text}, {"ShippingMode", Text.Trim, type text},
        {"Segment", Text.Trim, type text}, {"Market", Text.Trim, type text},
        {"OrderRegion", Text.Trim, type text}, {"Department", Text.Trim, type text},
        {"Category", Text.Trim, type text}, {"Product", Text.Trim, type text}}),

    // DQ-04: dates arrive as US month/day/year text. Typing with the "en-US" culture makes the
    // parse independent of the PC's regional settings (an Irish/UK PC would otherwise read 1/3 as 1 March).
    Typed = Table.TransformColumnTypes(Trimmed, {
        {"OrderId", Int64.Type}, {"OrderItemId", Int64.Type},
        {"OrderDateTime", type datetime}, {"ShipDateTime", type datetime},
        {"LateRiskFlag", Int64.Type}, {"ActualShipDays", Int64.Type}, {"ScheduledShipDays", Int64.Type},
        {"CustomerId", Int64.Type}, {"ProductId", Int64.Type},
        {"UnitPrice", type number}, {"Quantity", Int64.Type}, {"GrossSales", type number},
        {"Discount", type number}, {"DiscountRate", type number},
        {"NetSales", type number}, {"Profit", type number}}, "en-US"),

    AddMonthStart = Table.AddColumn(Typed, "MonthStart", each Date.StartOfMonth(DateTime.Date([OrderDateTime])), type date),
    AddPeriod = Table.AddColumn(AddMonthStart, "Period", each Date.ToText([MonthStart], [Format = "yyyy-MM", Culture = "en-US"]), type text),

    // DQ-07: "Shipping canceled" = order status CANCELED or SUSPECTED_FRAUD
    AddIsCancelled = Table.AddColumn(AddPeriod, "IsCancelled", each if [DeliveryStatus] = "Shipping canceled" then 1 else 0, Int64.Type)
in
    AddIsCancelled
