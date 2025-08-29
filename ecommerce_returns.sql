USE ecommerce;
select * from ecommerce_returns_synthetic_data;

SELECT 
    SUM(CASE WHEN Order_ID IS NULL OR TRIM(Order_ID) = '' THEN 1 ELSE 0 END) AS missing_Order_ID,
    SUM(CASE WHEN Product_ID IS NULL OR TRIM(Product_ID) = '' THEN 1 ELSE 0 END) AS missing_Product_ID,
    SUM(CASE WHEN User_ID IS NULL OR TRIM(User_ID) = '' THEN 1 ELSE 0 END) AS missing_User_ID,
    SUM(CASE WHEN Order_Date IS NULL OR TRIM(Order_Date) = '' THEN 1 ELSE 0 END) AS missing_Order_Date,
    SUM(CASE WHEN Return_Date IS NULL OR TRIM(Return_Date) = '' THEN 1 ELSE 0 END) AS missing_Return_Date,
    SUM(CASE WHEN Product_Category IS NULL OR TRIM(Product_Category) = '' THEN 1 ELSE 0 END) AS missing_Product_Category,
    SUM(CASE WHEN Product_Price IS NULL OR TRIM(Product_Price) = '' THEN 1 ELSE 0 END) AS missing_Product_Price,
    SUM(CASE WHEN Order_Quantity IS NULL OR TRIM(Order_Quantity) = '' THEN 1 ELSE 0 END) AS missing_Order_Quantity,
    SUM(CASE WHEN Return_Reason IS NULL OR TRIM(Return_Reason) = '' THEN 1 ELSE 0 END) AS missing_Return_Reason,
    SUM(CASE WHEN Return_Status IS NULL OR TRIM(Return_Status) = '' THEN 1 ELSE 0 END) AS missing_Return_Status,
    SUM(CASE WHEN Days_to_Return IS NULL OR TRIM(Days_to_Return) = '' THEN 1 ELSE 0 END) AS missing_Days_to_Return,
    SUM(CASE WHEN User_Age IS NULL OR TRIM(User_Age) = '' THEN 1 ELSE 0 END) AS missing_User_Age,
    SUM(CASE WHEN User_Gender IS NULL OR TRIM(User_Gender) = '' THEN 1 ELSE 0 END) AS missing_User_Gender,
    SUM(CASE WHEN User_Location IS NULL OR TRIM(User_Location) = '' THEN 1 ELSE 0 END) AS missing_User_Location,
    SUM(CASE WHEN Payment_Method IS NULL OR TRIM(Payment_Method) = '' THEN 1 ELSE 0 END) AS missing_Payment_Method,
    SUM(CASE WHEN Shipping_Method IS NULL OR TRIM(Shipping_Method) = '' THEN 1 ELSE 0 END) AS missing_Shipping_Method,
    SUM(CASE WHEN Discount_Applied IS NULL OR TRIM(Discount_Applied) = '' THEN 1 ELSE 0 END) AS missing_Discount_Applied
FROM ecommerce_returns_synthetic_data;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE ecommerce_returns_synthetic_data DROP COLUMN Return_Date, DROP COLUMN Days_to_Return;

UPDATE ecommerce_returns_synthetic_data SET Return_Reason = 'Not Mentioned' 
WHERE Return_Reason IS NULL OR TRIM(Return_Reason) = '';

SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Return_Status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(SUM(CASE WHEN Return_Status = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM ecommerce_returns_synthetic_data;


SELECT 
    Product_Category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Return_Status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(SUM(CASE WHEN Return_Status = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM ecommerce_returns_synthetic_data GROUP BY Product_Category ORDER BY return_rate_pct DESC;



SELECT 
    Product_ID,   
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Return_Status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(SUM(CASE WHEN Return_Status = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM ecommerce_returns_synthetic_data GROUP BY Product_ID ORDER BY return_rate_pct DESC;



SELECT 
    Return_Reason,
    COUNT(*) AS return_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ecommerce_returns_synthetic_data WHERE Return_Status = 'Returned'), 2) 
    AS pct_of_returns
FROM ecommerce_returns_synthetic_data WHERE Return_Status = 'Returned'
GROUP BY Return_Reason ORDER BY return_count DESC;


CREATE TABLE ecommerce_returns_export AS
SELECT 
    o.Order_ID,
    o.Product_ID,
    o.User_ID,
    o.Order_Date,
    o.Product_Category,
    o.Product_Price,
    o.Order_Quantity,
    o.Return_Reason,
    o.Return_Status,
    o.User_Age,
    o.User_Gender,
    o.User_Location,
    o.Payment_Method,
    o.Shipping_Method,
    o.Discount_Applied,

    -- overall return rate (same for all rows)
    overall.return_rate_pct AS overall_return_rate,

    -- category-level return rate
    cat.return_rate_pct AS category_return_rate,

    -- supplier/product-level return rate
    prod.return_rate_pct AS product_return_rate,

    -- geography-level return rate
    geo.return_rate_pct AS geography_return_rate,

    -- return reason % of all returns (only meaningful if returned)
    reason.pct_of_returns AS reason_pct_of_returns

FROM ecommerce_returns_synthetic_data o

-- overall return rate
CROSS JOIN (
    SELECT 
        ROUND(SUM(CASE WHEN Return_Status='Returned' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS return_rate_pct
    FROM ecommerce_returns_synthetic_data
) overall

-- category return %
LEFT JOIN (
    SELECT Product_Category,
           ROUND(SUM(CASE WHEN Return_Status='Returned' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS return_rate_pct
    FROM ecommerce_returns_synthetic_data
    GROUP BY Product_Category
) cat ON o.Product_Category = cat.Product_Category

-- product/supplier return %
LEFT JOIN (
    SELECT Product_ID,
           ROUND(SUM(CASE WHEN Return_Status='Returned' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS return_rate_pct
    FROM ecommerce_returns_synthetic_data
    GROUP BY Product_ID
) prod ON o.Product_ID = prod.Product_ID

-- geography return %
LEFT JOIN (
    SELECT User_Location,
           ROUND(SUM(CASE WHEN Return_Status='Returned' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS return_rate_pct
    FROM ecommerce_returns_synthetic_data
    GROUP BY User_Location
) geo ON o.User_Location = geo.User_Location

-- return reason %
LEFT JOIN (
    SELECT Return_Reason,
           ROUND(COUNT(*)*100.0 / (SELECT COUNT(*) FROM ecommerce_returns_synthetic_data WHERE Return_Status='Returned'),2) AS pct_of_returns
    FROM ecommerce_returns_synthetic_data
    WHERE Return_Status='Returned'
    GROUP BY Return_Reason
) reason ON o.Return_Reason = reason.Return_Reason;


SELECT * FROM ecommerce_returns_export LIMIT 20;











