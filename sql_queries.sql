


WITH brand_sales AS (
    SELECT
        s.Brand,
        s.Description,
        SUM(s.SalesQuantity)                                        AS TotalQtySold,
        SUM(s.SalesDollars)                                         AS TotalSalesDollars,
        SUM(s.SalesDollars - s.SalesQuantity * pp.PurchasePrice)    AS GrossProfit,
        CASE WHEN SUM(s.SalesDollars) > 0
             THEN ROUND(
                    SUM(s.SalesDollars - s.SalesQuantity * pp.PurchasePrice)
                    / SUM(s.SalesDollars) * 100, 2)
             ELSE 0
        END                                                         AS ProfitMarginPct
    FROM sales s
    LEFT JOIN purchase_prices pp
        ON  s.Brand       = pp.Brand
        AND s.Description = pp.Description
    GROUP BY s.Brand, s.Description
),
brand_inv AS (
    SELECT Brand, Description,
           SUM(onHand) AS EndOnHand
    FROM end_inventory
    GROUP BY Brand, Description
)
SELECT
    bs.Brand,
    bs.Description,
    bs.TotalQtySold,
    ROUND(bs.TotalSalesDollars, 2)   AS TotalSalesDollars,
    ROUND(bs.GrossProfit, 2)         AS GrossProfit,
    bs.ProfitMarginPct,
    COALESCE(bi.EndOnHand, 0)        AS EndInventoryOnHand
FROM brand_sales bs
LEFT JOIN brand_inv bi
    ON  bs.Brand       = bi.Brand
    AND bs.Description = bi.Description
WHERE bs.TotalQtySold > 0
ORDER BY bs.ProfitMarginPct ASC,
         bs.TotalSalesDollars ASC
LIMIT 30;



-- Q2  TOP VENDORS BY SALES AND GROSS PROFIT



SELECT
    s.VendorNo                                                      AS VendorNumber,
    s.VendorName,
    SUM(s.SalesQuantity)                                            AS TotalVolume,
    ROUND(SUM(s.SalesDollars), 2)                                   AS TotalSalesDollars,
    ROUND(
        SUM(s.SalesDollars
            - s.SalesQuantity * COALESCE(pp.PurchasePrice, 0)), 2)  AS GrossProfit,
    CASE WHEN SUM(s.SalesDollars) > 0
         THEN ROUND(
                SUM(s.SalesDollars
                    - s.SalesQuantity * COALESCE(pp.PurchasePrice, 0))
                / SUM(s.SalesDollars) * 100, 2)
         ELSE 0
    END                                                             AS ProfitMarginPct
FROM sales s
LEFT JOIN purchase_prices pp
    ON  s.Brand       = pp.Brand
    AND s.Description = pp.Description
GROUP BY s.VendorNo, s.VendorName
ORDER BY TotalSalesDollars DESC
LIMIT 15;



-- Q3  BULK PURCHASING IMPACT ON UNIT COST


SELECT
    CASE
        WHEN Quantity <=   5 THEN '1-Small (1-5)'
        WHEN Quantity <=  20 THEN '2-Medium (6-20)'
        WHEN Quantity <= 100 THEN '3-Large (21-100)'
        ELSE                      '4-Bulk (100+)'
    END                                                AS PurchaseTier,
    COUNT(*)                                           AS NumTransactions,
    SUM(Quantity)                                      AS TotalUnits,
    ROUND(SUM(Dollars), 2)                             AS TotalDollars,
    ROUND(SUM(Dollars) / NULLIF(SUM(Quantity), 0), 2)  AS AvgUnitCost
FROM purchases
GROUP BY PurchaseTier
ORDER BY PurchaseTier;



-- Q4  INVENTORY TURNOVER RATIO



WITH cogs AS (
    SELECT
        s.Brand,
        s.Description,
        SUM(s.SalesQuantity * COALESCE(pp.PurchasePrice, 0)) AS COGS
    FROM sales s
    LEFT JOIN purchase_prices pp
        ON  s.Brand       = pp.Brand
        AND s.Description = pp.Description
    GROUP BY s.Brand, s.Description
),
avg_inv AS (
    SELECT
        Brand, Description,
        AVG(InventoryValue) AS AvgInventoryValue
    FROM (
        SELECT Brand, Description,
               SUM(onHand * Price) AS InventoryValue
        FROM begin_inventory
        GROUP BY Brand, Description
        UNION ALL
        SELECT Brand, Description,
               SUM(onHand * Price) AS InventoryValue
        FROM end_inventory
        GROUP BY Brand, Description
    ) combined
    GROUP BY Brand, Description
)
SELECT
    c.Brand,
    c.Description,
    ROUND(c.COGS, 2)                                           AS COGS,
    ROUND(ai.AvgInventoryValue, 2)                              AS AvgInventoryValue,
    ROUND(c.COGS / NULLIF(ai.AvgInventoryValue, 0), 2)         AS InventoryTurnover
FROM cogs c
JOIN avg_inv ai
    ON  c.Brand       = ai.Brand
    AND c.Description = ai.Description
WHERE ai.AvgInventoryValue > 0
ORDER BY InventoryTurnover DESC
LIMIT 30;



-- Q5  PROFITABILITY VARIANCE - TOP 10 vs BOTTOM 10 VENDORS


WITH vendor_profit AS (
    SELECT
        s.VendorNo                                              AS VendorNumber,
        s.VendorName,
        SUM(s.SalesQuantity)                                    AS TotalQty,
        ROUND(SUM(s.SalesDollars), 2)                           AS TotalSales,
        ROUND(
            SUM(s.SalesDollars
                - s.SalesQuantity * COALESCE(pp.PurchasePrice, 0)), 2)
                                                                AS GrossProfit,
        CASE WHEN SUM(s.SalesDollars) > 0
             THEN ROUND(
                    SUM(s.SalesDollars
                        - s.SalesQuantity * COALESCE(pp.PurchasePrice, 0))
                    / SUM(s.SalesDollars) * 100, 2)
             ELSE 0
        END                                                     AS ProfitMarginPct
    FROM sales s
    LEFT JOIN purchase_prices pp
        ON  s.Brand       = pp.Brand
        AND s.Description = pp.Description
    GROUP BY s.VendorNo, s.VendorName
    HAVING SUM(s.SalesQuantity) >= 10
),
top_10 AS (
    SELECT *, 'Top 10' AS Tier
    FROM vendor_profit
    ORDER BY ProfitMarginPct DESC
    LIMIT 10
),
bottom_10 AS (
    SELECT *, 'Bottom 10' AS Tier
    FROM vendor_profit
    ORDER BY ProfitMarginPct ASC
    LIMIT 10
)
SELECT * FROM top_10
UNION ALL
SELECT * FROM bottom_10
ORDER BY ProfitMarginPct DESC;
