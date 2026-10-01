// Orders  (one row per order)  ->  load to sheet Data_Orders, cell A1
// Delivery KPIs are order-level: an order with 3 lines is one delivery, not three (DQ-02).
let
    Source = stg_Lines,
    Grouped = Table.Group(Source, {"OrderId"}, {
        {"OrderDate", each DateTime.Date(List.Min([OrderDateTime])), type date},
        {"MonthStart", each List.First([MonthStart]), type date},
        {"Period", each List.First([Period]), type text},
        {"CustomerId", each List.First([CustomerId]), Int64.Type},
        {"Segment", each List.First([Segment]), type text},
        {"Market", each List.First([Market]), type text},
        {"OrderRegion", each List.First([OrderRegion]), type text},
        {"PaymentType", each List.First([PaymentType]), type text},
        {"OrderStatus", each List.First([OrderStatus]), type text},
        {"DeliveryStatus", each List.First([DeliveryStatus]), type text},
        {"ShippingMode", each List.First([ShippingMode]), type text},
        {"ScheduledDays", each List.First([ScheduledShipDays]), Int64.Type},
        {"ActualDays", each List.First([ActualShipDays]), Int64.Type},
        {"IsCancelled", each List.Max([IsCancelled]), Int64.Type},
        {"Lines", each Table.RowCount(_), Int64.Type},
        {"Units", each List.Sum([Quantity]), Int64.Type},
        {"GrossSales", each List.Sum([GrossSales]), type number},
        {"Discount", each List.Sum([Discount]), type number},
        {"NetSales", each List.Sum([NetSales]), type number},
        {"Profit", each List.Sum([Profit]), type number}}),

    AddIsShipped = Table.AddColumn(Grouped, "IsShipped", each 1 - [IsCancelled], Int64.Type),
    // late = shipped and took longer than the promised (scheduled) days
    AddIsLate = Table.AddColumn(AddIsShipped, "IsLate", each if [IsShipped] = 1 and [ActualDays] > [ScheduledDays] then 1 else 0, Int64.Type),
    AddDelayDays = Table.AddColumn(AddIsLate, "DelayDays", each if [IsLate] = 1 then [ActualDays] - [ScheduledDays] else 0, Int64.Type),
    AddIsFraud = Table.AddColumn(AddDelayDays, "IsFraud", each if [OrderStatus] = "SUSPECTED_FRAUD" then 1 else 0, Int64.Type),

    // fixed column order: the workbook's named ranges point at these column positions
    Ordered = Table.SelectColumns(AddIsFraud, {
        "OrderId", "OrderDate", "MonthStart", "Period", "CustomerId", "Segment", "Market", "OrderRegion",
        "PaymentType", "OrderStatus", "DeliveryStatus", "ShippingMode", "ScheduledDays", "ActualDays",
        "IsCancelled", "IsShipped", "IsLate", "DelayDays", "IsFraud", "Lines", "Units",
        "GrossSales", "Discount", "NetSales", "Profit"}),
    Sorted = Table.Sort(Ordered, {{"OrderId", Order.Ascending}})
in
    Sorted
