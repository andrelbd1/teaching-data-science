-- 1. Second highest salary from the Employee
SELECT MAX(salary) AS SecondHighestSalary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);

-- 2. Find duplicate records from the Employee
SELECT name
     , count(*)
FROM employees e
GROUP BY name
HAVING  count(*) > 1;

-- 3. Retrieve employees who earn more than their manager.
select e.name as "Employee"
     , e.salary as "Employee Salary"
     , m.name as "Manager"
     , m.salary as "Manager Salary"
from employees as e
    inner join employees as m on e.id = m.manager_id
where e.salary > m.salary;

-- 4. Count employees in each department having more than 5 employees.
SELECT e.department_id, d.department_name
     , count(e.id)
FROM employees e
    left join departments d on e.department_id = d.department_id
GROUP BY 1, 2
HAVING  count(*) > 5;

-- 5. Find employees who joined in the last 6 months.
select e.*
from employees e
where e.hire_date >= current_date - INTERVAL '6 months'

-- 6. Get departments with no employees
SELECT d.department_id, d.department_name
FROM departments d
    left join employees e on e.department_id = d.department_id
where e.id is null;

-- 7. Write a query to find the median salary
with median_subquery as (
    SELECT salary
    FROM employees
    ORDER BY salary
    LIMIT 2 - (SELECT COUNT(*) FROM employees)%2
    OFFSET (SELECT (COUNT(*) - 1) / 2 FROM employees)
)
SELECT AVG(salary) AS median_salary
FROM median_subquery

-- 8. Running total of salaries by department
SELECT d.department_id, d.department_name
     , coalesce(sum(e.salary), 0) "total_salary"
FROM departments d
    left join employees e on e.department_id = d.department_id
GROUP BY 1, 2
ORDER BY 3 desc;

-- 9. Find the longest consecutive streak of daily logins for each user.
with login_dates as (
    select e.id, e.name, w.work_date
         , count(w.id) as "count_day"
    from employees e
        inner join work_logs w on e.id = w.employee_id
    group by e.id, e.name, w.work_date
    order by e.id
),
max_daily_logins as (
    select l.id, l.name, max(count_day) max_daily_logins
    from login_dates l
    group by l.id, l.name
    order by l.id
)
select l.*
from login_dates l
    inner join max_daily_logins m on m.id = l.id and l.count_day = m.max_daily_logins

-- 10. Recursive query to find the full reporting chain for each employee
with recursive reporting_chain as (
    select e.id, e.name, e.manager_id, 1 as level
    from employees as e
    where e.manager_id is null
    union
    select e.id, e.name, e.manager_id, r.level+1 as level
    from employees e
        inner join reporting_chain r on e.manager_id = r.id
)
select *
from reporting_chain
order by level, id;

-- 11. Write a query to find gaps in a sequence of numbers (missing manager IDs)
with sequence as (
    select generate_series(1, max(id)) as number
    from employees
)
select s.number as missing_id
from sequence s
where s.number not in (
    select distinct e.manager_id
    from employees e
    where manager_id is not null
)
order by missing_id;

-- 12. Calculate cumulative distribution (CDF) of salaries.
select e.name, e.salary
     , cume_dist() over (order by e.salary) as cumulative_salary
from employees e
order by e.salary;

-- 13. Write a query to rank employees based on salary with ties handled properly.
select e.name, e.salary
     , rank() over (order by e.salary desc)
from employees e
order by salary desc;

-- 14. Find customers who have not made any purchase.
select c.customer_id, c.name
from customers c
    left join company.sales s on c.customer_id = s.customer_id
where s.sale_id is null;

-- 15. Write a query to perform a conditional aggregation (count males and females in each department).
select d.department_id
     , d.department_name
     , case e.gender
        when 'F' then 'Female'
        when 'M' then 'Male'
        else 'Other'
       end as gender
    , count(*)
from departments d
    join employees e on d.department_id = e.department_id
group by d.department_id, d.department_name, e.gender
order by 1;

-- 16. Write a query to calculate the difference between current row and previous row's salary (lag function).
select e.name, e.salary
     , e.salary - lag(e.salary) over (order by e.id) as "salary_diff"
from employees e;

-- 17. Identify overlapping date ranges for projects.
select p1.project_name, p1.start_date, p1.end_date, p2.project_name, p2.start_date, p2.end_date
from projects p1
    join projects p2 on p1.project_id != p2.project_id
where p1.start_date <= p2.end_date and p1.end_date >= p2.start_date;

-- 18. Write a query to find employees with salary greater than average salary in the entire company, ordered by salary descending
select e.name, e.salary
from employees e
where salary > (select AVG(salary) from employees)
order by e.salary desc;

-- 19. Aggregate JSON data (if supported) to list all employee names in a department as a JSON array.
select d.department_id
     , json_agg(e.name) as names
from employees e join departments d on e.department_id = d.department_id
group by d.department_id
order by department_id;

-- 20. Find employees who have a salary greater than their manager.
select m.name as "manager", e.name as "employee", e.salary, m.salary
from employees e
    join employees m on e.manager_id = m.id and e.salary > m.salary
order by m.name;

-- 21. Write a query to get the first and last purchase date for each customer.
select c.customer_id, c.name
     , min(s.sale_date), max(s.sale_date)
from customers c
    join sales s on c.customer_id = s.customer_id
group by c.customer_id, c.name
order by c.customer_id;

-- 22. Find departments with the highest average salary.
select d.department_id, d.department_name
     , avg(e.salary) as "average_salary"
from employees e
    join departments d on e.department_id = d.department_id
group by d.department_id, d.department_name
having avg(e.salary) > (select AVG(salary) from employees);

-- 23. Write a query to find the number of employees in each job title.
select e.job_title
     , count(e.id)
from employees e
group by 1
order by 1;

-- 24. Find employees who don’t have a department assigned.
select e.*, d.department_id
from employees e
    left join departments d on e.department_id = d.department_id
where d.department_id is null;

-- 25. Write a query to find the difference in days between two dates.
select '2025-01-01' as start_date, '2025-02-10' as end_date,
    cast('2025-02-10' as DATE) - cast('2025-01-01' as DATE) as days_diff;

-- 26. Write a query to find the difference in months between two dates.
select '2024-12-01' as start_date, '2025-05-10' as end_date,
    EXTRACT(YEAR FROM AGE('2025-05-10', '2024-12-01')) * 12 +
    EXTRACT(MONTH FROM AGE('2025-05-10', '2024-12-01')) AS months_diff;

-- 27. Calculate the moving average of salaries over the last 3 employees ordered by hire date.
select e.name, e.hire_date, e.salary,
       avg(e.salary) over (order by e.hire_date rows between 2 preceding and current row) as moving_avg_salary
from employees e
order by e.hire_date;

-- 27. Find the most recent purchase per customer using window functions.
select *
from (
    select row_number() over (partition by s.customer_id order by s.sale_date desc) as row
         , s.*
    from sales as s
) sub
where row = 1;


-- 28. Detect max hierarchical depth of each manager in the org chart.
with recursive employee_depth as (
    select id, name, manager_id, 1 as level
    from employees
    where manager_id is null

    union

    select e.id, e.name, e.manager_id, ed.level+1 as level
    from employees e
             join employee_depth ed on e.manager_id = ed.id
)
-- Using group by
select manager_id
     , max(level)
from employee_depth
where manager_id is not null
group by 1
order by 1;

-- Using partition by
select manager_id, level
from (select manager_id, level, row_number() over (partition by manager_id order by level desc) as row
      from employee_depth) sub
where manager_id is not null
  and row = 1
order by manager_id;

-- 29. Write a query to pivot rows into columns dynamically.
select
    s.salesperson_id, e.name,
    sum(case when s.product_id = '1' then 1 else 0 end) as "Laptop Pro 15",
    sum(case when s.product_id = '2' then 1 else 0 end) as "Laptop Air 13",
    sum(case when s.product_id = '3' then 1 else 0 end) as "Gaming Mouse",
    sum(case when s.product_id = '4' then 1 else 0 end) as "Mechanical Keyboard",
    sum(case when s.product_id = '5' then 1 else 0 end) as "27-inch Monitor",
    sum(case when s.product_id = '6' then 1 else 0 end) as "Office Chair",
    sum(case when s.product_id = '7' then 1 else 0 end) as "Standing Desk",
    sum(case when s.product_id = '8' then 1 else 0 end) as "Noise-Cancel Headphones",
    sum(case when s.product_id = '9' then 1 else 0 end) as "Smartwatch",
    sum(case when s.product_id = '10' then 1 else 0 end) as "Webcam HD"
from sales s
     join products p on s.product_id = p.product_id
     join employees e on e.id = s.salesperson_id
group by 1, 2
order by 1;

-- 30. Find customers who made purchases in every category available.
select c.customer_id, c.name
from products p
    left join sales s on p.product_id = s.product_id
    join customers c on c.customer_id = s.customer_id
group by 1, 2
having count(distinct p.category_id) = (select count(distinct category_id) from products)
order by c.customer_id;

-- 31. Identify customers who haven’t purchased in more than a year.
select c.customer_id, c.name
from sales s
    join customers c on c.customer_id = s.customer_id
group by 1, 2
having max(s.sale_date) < current_date - interval '1 year'
order by 1, 2;

-- 32. Write a query to rank salespeople by monthly sales, resetting the rank every month.
with sales_month as (
    select e.id, e.name, to_char(s.sale_date, 'YYYY-MM') as "sales_date", sum(s.amount) "total_sales"
    from sales s
        join employees e on s.salesperson_id = e.id
    group by 1,2,3
    order by 3
)
select *
from (
        select s.sales_date, s.id, s.name, s.total_sales,
               rank() over (partition by s.sales_date order by total_sales desc) as rank
        from sales_month s
    ) sub
where rank <= 3;

-- 33. Calculate the percentage change in sales compared to the previous month for each product.
WITH months AS (
    SELECT to_char(d, 'YYYY-MM') AS sale_month
    FROM generate_series(
        (SELECT MIN(sale_date) FROM sales),
        (SELECT MAX(sale_date) FROM sales),
        interval '1 month'
    ) AS d
),
all_combinations as (
    select p.product_id, m.sale_month
    from products p
        cross join months m
),
all_sales as (
    select s.product_id, to_char(s.sale_date, 'YYYY-MM') as sale_month, sum(amount*quantity) as total_sales
    from sales s
    group by 1, 2
    order by 2, 1
),
aggregate_sales as (
    select c.product_id, p.product_name, c.sale_month, coalesce(sum(s.total_sales), 0) as total_sales
    from all_combinations c
        left join all_sales s on c.product_id = s.product_id and c.sale_month = s.sale_month
        left join products p on c.product_id = p.product_id
    group by 1, 2, 3
    order by 3, 1
)
select product_id, product_name, sale_month, total_sales,
       (total_sales-lag(total_sales) over (partition by product_id order by sale_month)) * 100 / NULLIF(lag(total_sales) over (partition by product_id order by sale_month), 0) as pct_change
from aggregate_sales;

-- 34. Find employees who earn more than the average salary across the company but less than the highest salary in their department.