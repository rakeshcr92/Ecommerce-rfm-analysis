
# 📊 RFM Customer Segmentation (SQL Project)

## ✅ Overview
Perform **RFM (Recency, Frequency, Monetary) Analysis** using SQL on an e-commerce dataset to segment customers into groups like **Champions**, **Loyal**, and **At Risk**.

---

## 🗂 Dataset
- `rfm_customers.csv` → customer_id, name, signup_date, region
- `rfm_orders.csv` → order_id, customer_id, order_date, amount, status

---

## 🛠 Tech Stack
- MySQL (SQL queries, CTEs, CASE)
- Optional: Tableau / Power BI for visualization

---

## ✅ Steps

### **1. Create Tables**
```sql
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  signup_date DATE,
  region VARCHAR(100)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  amount FLOAT,
  status VARCHAR(20),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### **2. Clean Data**
```sql
CREATE OR REPLACE VIEW clean_orders AS
SELECT * FROM orders WHERE status = 'Delivered';
```

### **3. RFM Calculation**
```sql
WITH rfm_base AS (
  SELECT customer_id,
         MAX(order_date) AS last_purchase,
         COUNT(*) AS frequency,
         SUM(amount) AS monetary
  FROM clean_orders
  GROUP BY customer_id
),
rfm_scores AS (
  SELECT customer_id,
         DATEDIFF('2025-07-14', last_purchase) AS recency,
         frequency,
         monetary,
         CASE WHEN DATEDIFF('2025-07-14', last_purchase) <= 7 THEN 5
              WHEN DATEDIFF('2025-07-14', last_purchase) <= 14 THEN 4
              WHEN DATEDIFF('2025-07-14', last_purchase) <= 30 THEN 3
              WHEN DATEDIFF('2025-07-14', last_purchase) <= 60 THEN 2
              ELSE 1 END AS r_score,
         CASE WHEN frequency >= 20 THEN 5
              WHEN frequency >= 10 THEN 4
              WHEN frequency >= 5 THEN 3
              WHEN frequency >= 2 THEN 2
              ELSE 1 END AS f_score,
         CASE WHEN monetary >= 1000 THEN 5
              WHEN monetary >= 500 THEN 4
              WHEN monetary >= 200 THEN 3
              WHEN monetary >= 100 THEN 2
              ELSE 1 END AS m_score
  FROM rfm_base
)
SELECT * FROM rfm_scores;
```

### **4. Segment Customers**
```sql
SELECT *, CONCAT(r_score,f_score,m_score) AS rfm_score,
       CASE WHEN r_score = 5 AND f_score >= 4 THEN 'Champion'
            WHEN r_score >= 4 AND f_score >= 4 THEN 'Loyal'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'At Risk'
            WHEN r_score = 5 AND f_score = 1 THEN 'New Customer'
            ELSE 'Others' END AS segment
FROM rfm_scores
ORDER BY rfm_score DESC;
```

---

## ✅ Files in Repo
- `rfm_customers.csv`
- `rfm_orders.csv`
- `schema.sql`
- `rfm_analysis.sql`
- `README.md`
