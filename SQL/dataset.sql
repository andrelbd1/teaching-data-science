-- Drop existing tables (safe reset)
DROP SCHEMA IF EXISTS company CASCADE;
CREATE SCHEMA company;
SET search_path TO company;

-- Employees and Departments
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    manager_id INT,
    budget NUMERIC(12,2),
    creation_date DATE
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    job_title VARCHAR(100),
    department_id INT REFERENCES departments(department_id),
    manager_id INT REFERENCES employees(id),
    hire_date DATE,
    salary NUMERIC(12,2),
    gender CHAR(1),
    country VARCHAR(50)
);

-- Customers and Orders
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    country VARCHAR(50),
    region VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    amount NUMERIC(12,2),
    shipping_method VARCHAR(50),
    shipping_date DATE
);

-- Products and Sales
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price NUMERIC(12,2),
    discontinued BOOLEAN DEFAULT FALSE,
    launch_date DATE
);

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id INT REFERENCES products(product_id),
    sale_date DATE,
    amount NUMERIC(12,2),
    quantity INT,
    salesperson_id INT REFERENCES employees(id)
);

-- Projects and Assignments
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    manager_id INT REFERENCES employees(id),
    start_date DATE,
    end_date DATE,
    budget NUMERIC(12,2)
);

CREATE TABLE project_assignments (
    employee_id INT REFERENCES employees(id),
    project_id INT REFERENCES projects(project_id),
    assignment_start_date DATE,
    assignment_end_date DATE,
    assignment_date DATE,
    PRIMARY KEY (employee_id, project_id)
);

-- Promotions and Salary History
CREATE TABLE promotions (
    promotion_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    promotion_date DATE,
    new_title VARCHAR(100)
);

CREATE TABLE salary_history (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    change_date DATE,
    raise_date DATE,
    old_salary NUMERIC(12,2),
    new_salary NUMERIC(12,2)
);

-- Dependents and Employee History
CREATE TABLE dependents (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    dependent_name VARCHAR(100),
    relationship VARCHAR(50)
);

CREATE TABLE employee_department_history (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    department_id INT REFERENCES departments(department_id),
    start_date DATE,
    end_date DATE
);

-- Logs and Work Records
CREATE TABLE work_logs (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    work_date DATE,
    hours_worked NUMERIC(5,2)
);

-- Product Reviews and Returns
CREATE TABLE product_reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    customer_id INT REFERENCES customers(customer_id),
    rating NUMERIC(2,1),
    review_date DATE
);

CREATE TABLE returns (
    return_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    return_date DATE
);

-- Suppliers and Deliveries
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE deliveries (
    delivery_id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(supplier_id),
    delivery_region VARCHAR(50),
    delivery_date DATE
);

-- Sales Deals and Invoices
CREATE TABLE sales_deals (
    deal_id SERIAL PRIMARY KEY,
    sales_rep_id INT REFERENCES employees(id),
    deal_close_date DATE,
    amount NUMERIC(12,2)
);

CREATE TABLE invoices (
    invoice_number SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    invoice_date DATE,
    total_amount NUMERIC(12,2)
);

-- Order Items
CREATE TABLE order_items (
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);

-- === DEPARTMENTS ===
INSERT INTO departments (department_name, budget, creation_date) VALUES
('IT', 1500000, '2018-01-01'),
('HR', 800000, '2019-03-15'),
('Finance', 1200000, '2020-06-10'),
('Sales', 2500000, '2017-08-01'),
('Operations', 1800000, '2016-11-20'),
('BI', 1100000.00, '2019-10-10');

-- === EMPLOYEES ===
INSERT INTO employees (name, job_title, department_id, manager_id, hire_date, salary, gender, country) VALUES
('Alice Johnson', 'CTO', 1, NULL, '2016-05-15', 180000, 'F', 'USA'),
('Bob Smith', 'Software Engineer', 1, 1, '2019-07-01', 95000, 'M', 'Canada'),
('Charlie Brown', 'Data Engineer', 1, 1, '2020-03-12', 105000, 'M', 'USA'),
('Diana Prince', 'HR Manager', 2, NULL, '2017-09-09', 120000, 'F', 'UK'),
('Eva Green', 'HR Analyst', 2, 4, '2021-01-11', 65000, 'F', 'USA'),
('Frank Moore', 'Accountant', 3, NULL, '2018-10-21', 85000, 'M', 'Brazil'),
('Grace Lee', 'Financial Analyst', 3, 6, '2020-05-15', 90000, 'F', 'Canada'),
('Henry Adams', 'Sales Director', 4, NULL, '2015-03-01', 140000, 'M', 'USA'),
('Isabella Clark', 'Sales Rep', 4, 8, '2019-09-09', 75000, 'F', 'USA'),
('John Miller', 'Sales Rep', 4, 8, '2020-07-07', 78000, 'M', 'UK'),
('Kevin White', 'Operations Manager', 5, NULL, '2016-11-11', 125000, 'M', 'Canada'),
('Laura Wilson', 'Ops Analyst', 5, 11, '2019-05-05', 70000, 'F', 'Brazil');

-- === CUSTOMERS ===
INSERT INTO customers (name, country, region, email) VALUES
('John Doe', 'USA', 'West', 'john.doe@email.com'),
('Jane Smith', 'USA', 'East', 'jane.smith@email.com'),
('Carlos Ruiz', 'Mexico', 'Central', 'carlos.ruiz@email.com'),
('Emily Davis', 'Canada', 'West', 'emily.davis@email.com'),
('Sophia Wang', 'China', 'East', 'sophia.wang@email.com'),
('Liam Connor', 'Ireland', 'North', 'liam.oconnor@email.com'),
('Hiro Tanaka', 'Japan', 'East', 'hiro.tanaka@email.com'),
('Olivia Brown', 'UK', 'South', 'olivia.brown@email.com'),
('Lucas Silva', 'Brazil', 'South', 'lucas.silva@email.com'),
('Emma Martinez', 'Spain', 'South', 'emma.martinez@email.com'),
('Josh White', 'Canada', 'East', 'josh.white@email.com');

-- === PRODUCTS ===
INSERT INTO products (product_name, category_id, price, discontinued, launch_date) VALUES
('Laptop Pro 15', 1, 1800, FALSE, '2021-01-01'),
('Laptop Air 13', 1, 1300, FALSE, '2022-03-01'),
('Gaming Mouse', 2, 70, FALSE, '2020-06-15'),
('Mechanical Keyboard', 2, 120, FALSE, '2019-09-09'),
('27-inch Monitor', 3, 300, FALSE, '2018-05-20'),
('Office Chair', 4, 250, FALSE, '2019-11-11'),
('Standing Desk', 4, 500, FALSE, '2020-01-01'),
('Noise-Cancel Headphones', 5, 200, TRUE, '2017-04-04'),
('Smartwatch', 5, 350, FALSE, '2022-07-07'),
('Webcam HD', 2, 90, FALSE, '2021-05-10');

-- === ORDERS ===
INSERT INTO orders (customer_id, order_date, amount, shipping_method, shipping_date) VALUES
(1, '2023-02-01', 1870, 'Air', '2023-02-05'),
(2, '2023-02-02', 310, 'Ground', '2023-02-08'),
(3, '2023-03-05', 320, 'Air', '2023-03-10'),
(4, '2023-03-07', 2300, 'Air', '2023-03-12'),
(5, '2023-03-08', 600, 'Ground', '2023-03-13'),
(6, '2023-03-10', 900, 'Air', '2023-03-14'),
(7, '2023-03-11', 1300, 'Sea', '2023-03-20'),
(8, '2023-03-12', 250, 'Ground', '2023-03-16'),
(9, '2023-03-13', 2100, 'Air', '2023-03-17'),
(10, '2023-03-14', 3200, 'Air', '2023-03-18');

-- === ORDER ITEMS ===
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1), (1, 3, 1), (2, 4, 1), (3, 5, 1), (4, 6, 2),
(5, 7, 1), (6, 2, 1), (7, 9, 2), (8, 10, 3), (9, 8, 1), (10, 1, 2);

-- === SALES ===
INSERT INTO sales (customer_id, product_id, sale_date, amount, quantity, salesperson_id) VALUES
(1, 1, '2023-02-01', 1800, 1, 9),
(1, 3, '2023-02-01', 70, 1, 10),
(2, 4, '2023-02-02', 120, 1, 9),
(3, 5, '2023-03-05', 300, 1, 10),
(4, 6, '2023-03-07', 500, 2, 8),
(5, 7, '2023-03-08', 500, 1, 9),
(6, 2, '2023-03-10', 1300, 1, 9),
(7, 9, '2023-03-11', 700, 2, 10),
(8, 10, '2023-03-12', 270, 3, 9),
(9, 8, '2023-03-13', 200, 1, 8),
(10, 1, '2023-03-14', 3600, 2, 10),
(1, 3, '2023-02-20', 10, 1, 5),
(1, 2, '2023-03-05', 555, 5, 9),
(1, 2, '2023-03-06', 100, 1, 9),
(1, 4, '2023-03-16', 10, 1, 7),
(2, 4, '2023-02-03', 111, 1, 10),
(2, 2, '2023-05-03', 1, 1, 10),
(2, 1, '2023-06-03', 2, 1, 9),
(3, 3, '2023-04-01', 30, 12, 2),
(3, 3, '2023-08-21', 3, 10, 2),
(4, 2, '2023-05-17', 100, 1, 7),
(4, 1, '2023-08-02', 50, 3, 2),
(5, 7, '2024-01-02', 5, 2, 8),
(5, 2, '2024-04-01', 8, 1, 7),
(6, 1, '2023-04-21', 13, 2, 1),
(7, 2, '2023-05-23', 70, 3, 2),
(8, 3, '2023-06-24', 20, 4, 3),
(9, 4, '2023-07-25', 2, 5, 4),
(10, 5, '2023-08-05', 30, 6, 5),
(6, 6, '2023-09-15', 100, 7, 6),
(7, 7, '2023-10-14', 70, 8, 7),
(8, 8, '2023-11-11', 20, 9, 8),
(9, 1, '2023-12-19', 250, 10, 8),
(10, 3, '2024-01-12', 360, 20, 10);

-- === PROJECTS ===
INSERT INTO projects (project_name, manager_id, start_date, end_date, budget) VALUES
('Data Pipeline Migration', 1, '2022-01-10', '2023-02-10', 200000),
('HR Onboarding Portal', 4, '2022-05-01', '2023-03-01', 80000),
('Financial Dashboard', 6, '2021-07-15', '2022-12-15', 150000),
('Sales CRM Integration', 8, '2022-02-01', '2023-01-30', 120000),
('Warehouse Automation', 11, '2022-04-01', '2023-04-01', 300000);

-- === PROJECT ASSIGNMENTS ===
INSERT INTO project_assignments (employee_id, project_id, assignment_start_date, assignment_end_date) VALUES
(2, 1, '2022-01-10', '2023-02-10'),
(3, 1, '2022-02-01', '2023-02-10'),
(5, 2, '2022-05-01', '2023-03-01'),
(6, 3, '2021-07-15', '2022-12-15'),
(7, 3, '2021-08-01', '2022-12-15'),
(9, 4, '2022-02-01', '2023-01-30'),
(10, 4, '2022-03-01', '2023-01-30'),
(11, 5, '2022-04-01', '2023-04-01'),
(12, 5, '2022-05-01', '2023-04-01');

-- === PROMOTIONS ===
INSERT INTO promotions (employee_id, promotion_date, new_title) VALUES
(2, '2021-08-01', 'Senior Engineer'),
(3, '2022-03-01', 'Lead Data Engineer'),
(5, '2022-06-01', 'HR Specialist'),
(9, '2023-01-01', 'Account Executive'),
(10, '2023-02-01', 'Senior Sales Rep');

-- === SALARY HISTORY ===
INSERT INTO salary_history (employee_id, change_date, old_salary, new_salary) VALUES
(2, '2021-08-01', 85000, 95000),
(3, '2022-03-01', 90000, 105000),
(5, '2022-06-01', 60000, 65000),
(9, '2023-01-01', 70000, 75000),
(10, '2023-02-01', 72000, 78000);

-- === DEPENDENTS ===
INSERT INTO dependents (employee_id, dependent_name, relationship) VALUES
(1, 'Michael Johnson', 'Son'),
(4, 'Sarah Prince', 'Daughter'),
(6, 'James Moore', 'Son'),
(8, 'Anna Adams', 'Spouse'),
(9, 'Peter Clark', 'Son'),
(10, 'Lily Miller', 'Daughter');

-- === WORK LOGS ===
INSERT INTO work_logs (employee_id, work_date, hours_worked) VALUES
(2, '2023-01-02', 8), (2, '2023-01-03', 7.5),
(3, '2023-01-02', 8), (3, '2023-01-03', 8),
(9, '2023-01-02', 9), (10, '2023-01-02', 8),
(11, '2023-01-02', 7), (12, '2023-01-02', 7.5),
(2, '2023-01-04', 8.0), (2, '2023-01-05', 7.5),
(2, '2023-01-06', 9.0), (3, '2023-01-04', 8.0),
(3, '2023-01-05', 8.0), (3, '2023-01-06', 8.5),
(5, '2023-01-04', 7.0), (5, '2023-01-05', 7.5),
(5, '2023-01-06', 7.0), (9, '2023-01-04', 9.5),
(9, '2023-01-05', 8.0), (9, '2023-01-06', 8.0),
(10, '2023-01-04', 8.0), (10, '2023-01-05', 8.0),
(10, '2023-01-06', 8.0), (2, '2023-02-01', 1.0),
(2, '2023-02-01', 2.0), (2, '2023-02-01', 1.0),
(2, '2023-02-01', 3.0), (2, '2023-02-01', 0.5),
(2, '2023-02-01', 1.0), (2, '2023-02-02', 2.5),
(2, '2023-02-02', 2.5), (2, '2023-02-02', 0.5),
(2, '2023-02-03', 1.5), (2, '2023-02-03', 3.5),
(3, '2023-02-01', 8.0), (3, '2023-02-02', 5.0),
(3, '2023-02-02', 1.0), (3, '2023-02-03', 9.0),
(5, '2023-02-01', 7.0), (5, '2023-02-01', 1.0),
(5, '2023-02-02', 7.5), (6, '2023-02-01', 8.0),
(6, '2023-02-02', 4.5), (6, '2023-02-02', 1.5),
(6, '2023-02-02', 2.5), (6, '2023-02-03', 8.0),
(9, '2023-02-01', 8.0), (9, '2023-02-01', 1.0),
(9, '2023-02-02', 8.0), (9, '2023-02-03', 5.5),
(9, '2023-02-03', 2.5), (10, '2023-02-01', 8.0),
(10, '2023-02-02', 2.5), (10, '2023-02-02', 5.5),
(11, '2023-02-01', 7.5), (11, '2023-02-01', 0.5),
(11, '2023-02-02', 8.0), (12, '2023-02-01', 7.0),
(12, '2023-02-01', 0.5), (12, '2023-02-01', 0.5),
(12, '2023-02-02', 7.5), (2, '2023-03-01', 8.0),
(2, '2023-03-02', 7.0), (2, '2023-03-02', 1.0),
(2, '2023-03-03', 8.5), (3, '2023-03-01', 8.0),
(3, '2023-03-02', 8.5), (3, '2023-03-03', 8.0),
(3, '2023-03-03', 1.0), (5, '2023-03-01', 7.0),
(5, '2023-03-01', 0.5), (5, '2023-03-01', 0.5),
(5, '2023-03-01', 0.5), (5, '2023-03-01', 0.5),
(5, '2023-03-02', 7.0), (5, '2023-03-02', 1.0),
(5, '2023-03-03', 7.5), (6, '2023-03-01', 8.0),
(6, '2023-03-01', 1.0), (6, '2023-03-02', 8.5),
(6, '2023-03-03', 9.0), (9, '2023-03-01', 8.5),
(9, '2023-03-02', 5.0), (9, '2023-03-02', 2.0),
(9, '2023-03-03', 9.5), (10, '2023-03-01', 8.0),
(10, '2023-03-01', 1.0), (10, '2023-03-02', 8.0),
(10, '2023-03-03', 8.0), (11, '2023-03-01', 7.5),
(11, '2023-03-02', 8.0), (12, '2023-03-01', 7.0),
(12, '2023-03-01', 0.5), (12, '2023-03-01', 0.5),
(12, '2023-03-02', 7.5), (12, '2023-03-02', 1.5);

-- === PRODUCT REVIEWS ===
INSERT INTO product_reviews (product_id, customer_id, rating, review_date) VALUES
(1, 1, 4.5, '2023-03-01'),
(2, 2, 4.8, '2023-03-02'),
(3, 3, 3.9, '2023-03-03'),
(4, 4, 4.0, '2023-03-04'),
(5, 5, 4.2, '2023-03-05'),
(6, 6, 3.8, '2023-03-06'),
(7, 7, 4.9, '2023-03-07'),
(8, 8, 3.6, '2023-03-08'),
(9, 9, 4.4, '2023-03-09'),
(10, 10, 4.7, '2023-03-10');

-- === SUPPLIERS & DELIVERIES ===
INSERT INTO suppliers (supplier_name, region) VALUES
('TechSource', 'North America'),
('GlobalParts', 'Europe'),
('AsiaSupply', 'Asia'),
('LATAM Logistics', 'South America'),
('EuroTech', 'Europe');

INSERT INTO deliveries (supplier_id, delivery_region, delivery_date) VALUES
(1, 'North America', '2023-02-01'),
(2, 'Europe', '2023-02-05'),
(3, 'Asia', '2023-02-10'),
(4, 'South America', '2023-02-15'),
(5, 'Europe', '2023-02-20');

-- === SALES DEALS ===
INSERT INTO sales_deals (sales_rep_id, deal_close_date, amount) VALUES
(9, '2023-03-10', 15000),
(10, '2023-03-15', 18000),
(9, '2023-03-20', 25000),
(10, '2023-03-25', 12000),
(8, '2023-03-30', 30000);

-- === INVOICES ===
INSERT INTO invoices (customer_id, invoice_date, total_amount) VALUES
(1, '2023-03-01', 1870),
(2, '2023-03-02', 310),
(3, '2023-03-05', 320),
(4, '2023-03-07', 2300),
(5, '2023-03-08', 600),
(6, '2023-03-10', 900),
(7, '2023-03-11', 1300),
(8, '2023-03-12', 250),
(9, '2023-03-13', 2100),
(10, '2023-03-14', 3200);
