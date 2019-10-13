DROP DATABASE bar;
CREATE DATABASE bar;
\c bar;

CREATE TABLE order_line(
order_line_number INTEGER PRIMARY KEY
);

CREATE TABLE dates (
dates DATE PRIMARY KEY,
years INTEGER,
months INTEGER,
day_of_month INTEGER,
day_of_week INTEGER,
quarter INTEGER
);

CREATE TABLE offices (
office_code INTEGER PRIMARY KEY,
office_city VARCHAR,
office_state VARCHAR,
office_country VARCHAR,
office_location VARCHAR
);

CREATE TABLE empl (
employee_number INTEGER PRIMARY KEY,
last_name VARCHAR,
first_name VARCHAR,
job_title VARCHAR
);

CREATE TABLE customers (
customer_number INTEGER PRIMARY KEY,
customer_name VARCHAR,
customer_city VARCHAR,
customer_state VARCHAR,
customer_country VARCHAR,
customer_location VARCHAR
);

CREATE TABLE products (
product_code VARCHAR PRIMARY KEY,
product_line VARCHAR,
product_name VARCHAR,
product_scale VARCHAR,
product_vendor VARCHAR,
product_description VARCHAR
);

CREATE TABLE orders (
order_number INTEGER PRIMARY KEY,
status VARCHAR,
comments VARCHAR
);


CREATE TABLE measures (
price_each FLOAT,
quantity_ordered INTEGER,
buy_price FLOAT,
_m_s_r_p FLOAT,
revenue FLOAT,
cost FLOAT,
profit FLOAT,
margin FLOAT,
credit_limit INTEGER,
quantity_in_stock INTEGER,
order_number INTEGER REFERENCES orders(order_number),
product_code VARCHAR REFERENCES products(product_code),
order_line_number INTEGER REFERENCES order_line(order_line_number),
order_date DATE REFERENCES dates(dates),
shipped_date DATE REFERENCES dates(dates),
required_date DATE REFERENCES dates(dates),
office_code INTEGER REFERENCES offices(office_code),
customer_number INTEGER REFERENCES customers(customer_number),
reports_to INTEGER REFERENCES empl(employee_number),
sales_rep_employee_number INTEGER REFERENCES empl(employee_number)
);