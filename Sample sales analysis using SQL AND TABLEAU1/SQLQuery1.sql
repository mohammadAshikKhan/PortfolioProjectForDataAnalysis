USE PortfolioProjectDB
---Inspecting Data
SELECT TOP 100 *
FROM sales_data_sample;

--Checking unique values
SELECT DISTINCT status
FROM sales_data_sample;

SELECT DISTINCT YEAR_ID
FROM sales_data_sample;

SELECT DISTINCT PRODUCTLINE
FROM sales_data_sample;

SELECT DISTINCT COUNTRY 
FROM sales_data_sample
ORDER BY COUNTRY  DESC;

SELECT DISTINCT DEALSIZE  
FROM sales_data_sample;


SELECT DISTINCT TERRITORY   
FROM sales_data_sample;


SELECT DISTINCT MONTH_ID
FROM sales_data_sample
WHERE YEAR_ID = 2003;

---ANALYSIS
----Let's start by grouping sales by productline
SELECT PRODUCTLINE, SUM(sales) Revenue
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY Revenue DESC ;

----Let's start by grouping sales by YEAR_ID

SELECT YEAR_ID, SUM(sales) Revenue
FROM sales_data_sample
GROUP BY YEAR_ID;


----Let's start by grouping sales by PRODUCTLINE and YEAR_ID
SELECT PRODUCTLINE, YEAR_ID, SUM(sales) Revenue
FROM sales_data_sample
GROUP BY YEAR_ID, PRODUCTLINE;


----Let's start by grouping sales by DEALSIZE
SELECT DEALSIZE, SUM(sales) Revenue
FROM sales_data_sample
GROUP BY DEALSIZE;


----What was the best month for sales in a specific year? How much was earned that month? 
SELECT MONTH_ID, SUM(sales) Revenue, COUNT(ORDERDATE) Frequency
FROM sales_data_sample
WHERE YEAR_ID = 2003 
GROUP BY MONTH_ID
ORDER BY 2 DESC;

--November seems to be the month, what product do they sell in November, Classic I believe
SELECT MONTH_ID, PRODUCTLINE, SUM(sales) Revenue, COUNT(ORDERDATE) Frequency
FROM sales_data_sample
WHERE YEAR_ID = 2003 AND MONTH_ID= 11
GROUP BY  PRODUCTLINE,MONTH_ID
ORDER BY 3 DESC;

----Who is our best customer (this could be best answered with RFM)
DROP TABLE IF EXISTS #rfm
;WITH rfm AS (
SELECT CUSTOMERNAME, 
		SUM(sales) MonetaryValue,
		AVG(sales) AvgMonetaryValue,
		COUNT(ORDERNUMBER) Frequency,
		MAX(ORDERDATE) last_order_date,
		(SELECT MAX(ORDERDATE) FROM sales_data_sample) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (SELECT max(ORDERDATE) FROM sales_data_sample)) Recency
FROM sales_data_sample
--WHERE YEAR_ID= 2003
GROUP BY CUSTOMERNAME
),
rfm_calc AS
(SELECT a.*,
        NTILE(4) OVER (ORDER BY Recency DESC) rfm_recency,
		NTILE(4) OVER (ORDER BY Frequency ) rfm_frequency,
		NTILE(4) OVER (ORDER BY MonetaryValue ) rfm_monetary
FROM rfm a
)
SELECT b.*, rfm_recency+ rfm_frequency+ rfm_monetary  rfm_cell,
 CONVERT(VARCHAR, rfm_recency) + CAST(rfm_frequency AS VARCHAR)+ CONVERT(vARCHAR, rfm_monetary) rfm_cell_string
  INTO #rfm
FROM rfm_calc b

SELECT CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
   CASE
       WHEN rfm_cell_string IN (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) THEN 'lost_customers'
	    WHEN rfm_cell_string IN (133, 134, 143, 244, 334, 343, 344, 144) THEN 'slipping away, cannot lose'
		 WHEN rfm_cell_string IN (311, 411, 331) THEN  'potential churners'
		 WHEN rfm_cell_string IN (323, 333,321, 422, 332, 432) THEN  'active'
		  WHEN rfm_cell_string IN (433, 434, 443, 444) THEN  'loyal'
		  END rfm_segment
FROM #rfm

--What products are most often sold together? 

SELECT DISTINCT OrderNumber, stuff(
		(SELECT'.' + PRODUCTCODE PRODUCTCODE_WITH_COMMA
		FROM sales_data_sample
		WHERE ORDERNUMBER IN
				(SELECT ORDERNUMBER
				FROM
				(
							SELECT ORDERNUMBER, COUNT(*)rn
							FROM sales_data_sample
							WHERE STATUS = 'Shipped'
							GROUP BY ORDERNUMBER
				)m
				WHERE rn = 2
				)
				FOR XML PATH('')) , 1, 1, '') xmlPathhToConvertString

FROM sales_data_sample
ORDER BY 2;
--select * from [dbo].[sales_data_sample] where ORDERNUMBER =  10102

---EXTRAs----
--What city has the highest number of sales in a specific country


SELECT CITY, SUM(sales) Revenue
FROM sales_data_sample
WHERE COUNTRY='UK'
GROUP BY CITY
ORDER BY 2 DESC;


---What is the best product in United States?
SELECT country, YEAR_ID, PRODUCTLINE, SUM(sales) Revenue
FROM sales_data_sample
WHERE country = 'USA'
GROUP  BY country, YEAR_ID, PRODUCTLINE
ORDER BY 4 DESC;