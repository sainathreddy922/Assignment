use assignment;
select * from dbo.sales;
select * from dbo.returns;

-- A.What % of sales result in a return?
SELECT 
    (CAST(COUNT(DISTINCT r.OrderID) AS FLOAT) / COUNT(DISTINCT s.OrderID)) * 100 AS ReturnPercentage
FROM  dbo.Sales s LEFT JOIN dbo.Returns r ON s.OrderID = r.OrderID;

-- B.What % of returns are full returns?
SELECT 
    (CAST(SUM(CASE WHEN r.ReturnSales = s.Sales THEN 1 ELSE 0 END) AS FLOAT) / 
	COUNT(r.OrderID)) * 100 AS FullReturnPercentage
FROM dbo.Returns r inner join  dbo.Sales s ON r.OrderID = s.OrderID;


-- C) What is the average return % amount (return % of original sale)?
SELECT
    AVG(CAST(r.ReturnSales AS FLOAT) / CAST(s.Sales AS FLOAT) * 100) AS AverageReturnPercentage FROM
dbo.Returns r inner join dbo.Sales s ON r.OrderID = s.OrderID;

-- D) What % of returns occur within 7 days of the original sale?
WITH ReturnsWithDays AS (
    SELECT
        r.OrderID,
        CONVERT(DATE, CONVERT(VARCHAR(8), s.transactiondate), 112) AS TransactionDate,
        CONVERT(DATE, CONVERT(VARCHAR(8), r.returndate), 112) AS ReturnDate,
        DATEDIFF(day, 
                  CONVERT(DATE, CONVERT(VARCHAR(8), s.transactiondate), 112), 
                  CONVERT(DATE, CONVERT(VARCHAR(8), r.returndate), 112)
                 ) AS DaysBetween FROM dbo.Returns r inner join dbo.Sales s ON r.OrderID = s.OrderID
)
SELECT
    CAST(COUNT(CASE WHEN DaysBetween <= 7 THEN 1 END) AS FLOAT) / 
	COUNT(*) * 100 AS PercentageReturnsWithin7Days
FROM ReturnsWithDays;

-- E.What is the average number of days for a return to occur?
WITH ReturnsWithDays AS (
    SELECT
        r.OrderID,
        CONVERT(DATE, CONVERT(VARCHAR(8), r.ReturnDate), 112) AS ReturnDate,
        CONVERT(DATE, CONVERT(VARCHAR(8), s.TransactionDate), 112) AS TransactionDate,
        DATEDIFF(day, CONVERT(DATE, CONVERT(VARCHAR(8), s.TransactionDate), 112), CONVERT(DATE, CONVERT(VARCHAR(8), r.ReturnDate), 112)) AS DaysBetween
    FROM dbo.Returns r inner join dbo.Sales s ON r.OrderID = s.OrderID )
SELECT
    AVG(DaysBetween) AS AverageDaysForReturn FROM ReturnsWithDays;

--F.Using this data set, how would you approach and answer the question,who is our most valuable customer?
SELECT top 1 s.customerid,
    SUM(COALESCE(TRY_CAST(REPLACE(s.sales, '$', '') AS DECIMAL(10, 2)), 0)) - 
    SUM(COALESCE(TRY_CAST(REPLACE(r.returnsales, '$', '') AS DECIMAL(10, 2)), 0)) AS total
FROM dbo.sales AS s LEFT JOIN dbo.returns AS r ON r.customerid = s.customerid
GROUP BY s.customerid
order by total desc;


