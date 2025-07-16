CREATE DATABASE rfm_analysis;
USE rfm_analysis;

DROP table customers;

CREATE TABLE customers(
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
