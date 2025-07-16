SELECT * FROM rfm_analysis.orders;

-- Cleaning Data
CREATE OR REPLACE VIEW clean_orders AS
SELECT *
FROM orders
WHERE status = 'Delivered'
AND customer_id IS NOT NULL
AND order_date IS NOT NULL
AND amount IS NOT NULL
AND amount > 0;

SELECT * FROM clean_orders;

USE rfm_analysis;
-- Use a reference date (e.g., today)
WITH rfm_base AS (
  SELECT
    customer_id,
    MAX(order_date) AS last_purchase,
    COUNT(*) AS frequency,
    SUM(amount) AS monetary
  FROM clean_orders
  GROUP BY customer_id
),
rfm_with_recency AS (
  SELECT
    customer_id,
    DATEDIFF('2025-07-14', last_purchase) AS recency,
    frequency,
    monetary
  FROM rfm_base
)
SELECT * FROM rfm_with_recency
order by monetary DESC;


WITH rfm_base AS(
	SELECT 
    customer_id, 
    MAX(order_date) AS last_purchase,
    COUNT(*) AS frequency,
    SUM(amount) AS monetary
    FROM clean_orders
    GROUP BY customer_id
    ),
    rfm_scores AS (
		SELECT
			customer_id, 
            DATEDIFF('2025-07-16', last_purchase) AS recency,
            frequency,
            monetary,
            
	 CASE
		WHEN frequency >=20 THEN 5
        WHEN frequency >=10 THEN 4
        WHEN frequency >=5 THEN 3
        WHEN frequency >=2 THEN 2
        ELSE 1
        
	END as f_score,
    
    CASE
		WHEN DATEDIFF('2025-07-16', last_purchase)<=7 THEN 5
		WHEN DATEDIFF('2025-07-16', last_purchase)<=14 THEN 4
		WHEN DATEDIFF('2025-07-16', last_purchase)<=30 THEN 3
		WHEN DATEDIFF('2025-07-16', last_purchase)<=60 THEN 2
        ELSE 1
        
	END as r_score,
    
    CASE
		WHEN monetary>=1000 THEN 5
		WHEN monetary>=500 THEN 4
		WHEN monetary>=200 THEN 3
		WHEN monetary>=100 THEN 2
        ELSE 1
	END as m_score
    
    FROM rfm_base
    )
    
SELECT * from rfm_base;

WITH rfm_base AS (
  SELECT
    customer_id,
    MAX(order_date) AS last_purchase,
    COUNT(*) AS frequency,
    SUM(amount) AS monetary
  FROM clean_orders
  GROUP BY customer_id
),
rfm_scores AS (
  SELECT
    customer_id,
    DATEDIFF('2025-07-14', last_purchase) AS recency,
    frequency,
    monetary,
    
    CASE
      WHEN DATEDIFF('2025-07-14', last_purchase) <= 7 THEN 5
      WHEN DATEDIFF('2025-07-14', last_purchase) <= 14 THEN 4
      WHEN DATEDIFF('2025-07-14', last_purchase) <= 30 THEN 3
      WHEN DATEDIFF('2025-07-14', last_purchase) <= 60 THEN 2
      ELSE 1
    END AS r_score,
    
    CASE
      WHEN frequency >= 20 THEN 5
      WHEN frequency >= 10 THEN 4
      WHEN frequency >= 5 THEN 3
      WHEN frequency >= 2 THEN 2
      ELSE 1
    END AS f_score,
    
    CASE
      WHEN monetary >= 1000 THEN 5
      WHEN monetary >= 500 THEN 4
      WHEN monetary >= 200 THEN 3
      WHEN monetary >= 100 THEN 2
      ELSE 1
    END AS m_score
  FROM rfm_base
),
rfm_final AS (
  SELECT *,
    CONCAT(r_score, f_score, m_score) AS rfm_score,
    CASE
      WHEN r_score = 5 AND f_score >= 4 THEN 'Champion'
      WHEN r_score >= 4 AND f_score >= 4 THEN 'Loyal'
      WHEN r_score <= 2 AND f_score <= 2 THEN 'At Risk'
      WHEN r_score = 5 AND f_score = 1 THEN 'New Customer'
      WHEN m_score >= 4 THEN 'Big Spender'
      ELSE 'Others'
    END AS segment
  FROM rfm_scores
)
SELECT * FROM rfm_final
ORDER BY rfm_score DESC;





Error Code: 1146. Table 'rfm_analysis.rfm_scores' doesn't exist
