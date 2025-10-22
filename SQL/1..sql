-- 1. Second highest salary from the Employee
SELECT MAX(salary) AS SecondHighestSalary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);

-- 2. Find duplicate records from the Employee
SELECT name, count(*)
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
SELECT e.department_id, d.department_name, count(e.id)
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
SELECT d.department_id, d.department_name, coalesce(sum(e.salary), 0) "total_salary"
FROM departments d
    left join employees e on e.department_id = d.department_id
GROUP BY 1, 2
ORDER BY 3 desc;

-- 9. Find the longest consecutive streak of daily logins for each user.
with login_dates as (
    select e.id, e.name, w.work_date, count(w.id) as "count_day"
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
select e.name, e.salary, cume_dist() over (order by e.salary) as cumulative_salary
from employees e
order by e.salary;

-- 13. Write a query to rank employees based on salary with ties handled properly.
select e.name, e.salary, rank() over (order by e.salary desc)
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
select e.name, e.salary, e.salary - lag(e.salary) over (order by e.id) as "salary_diff"
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
select d.department_id, json_agg(e.name) as names
from employees e join departments d on e.department_id = d.department_id
group by d.department_id
order by department_id;


-- 20. Find employees who have a salary greater than their manager.
select m.name as "manager", e.name as "employee", e.salary, m.salary
from employees e
    join employees m on e.manager_id = m.id and e.salary > m.salary
order by m.name;

-- 21. Write a query to get the first and last purchase date for each customer.
select c.customer_id, c.name, min(s.sale_date), max(s.sale_date)
from customers c
    join sales s on c.customer_id = s.customer_id
group by c.customer_id, c.name
order by c.customer_id;

-- 22. Find departments with the highest average salary.
select d.department_id, d.department_name, avg(e.salary) as "average_salary"
from employees e
    join departments d on e.department_id = d.department_id
group by d.department_id, d.department_name
having avg(e.salary) > (select AVG(salary) from employees);

-- 23. Write a query to find the number of employees in each job title.
select e.job_title, count(e.id)
from employees e
group by 1
order by 1;


-- 24. Find employees who don’t have a department assigned.
select e.*, d.department_id
from employees e
    left join departments d on e.department_id = d.department_id
where d.department_id is null;