-- Определить, во сколько раз зарплата каждого сотрудника
-- меньше максимальной зарплаты по компании.
select employee_id, first_name, last_name, salary,
       (max(salary) over ()) / salary  as ratio_max
from employees;

-- Определить, во сколько раз зарплата сотрудника
-- отличается от средней зарплаты по департаменту.
select employee_id, first_name, last_name, salary,
       salary / (avg(salary) over ())  as ratio_avg
from employees;

-- Вывести список всех сотрудников.
-- Для каждого сотрудника вывести среднюю зарплату по департаменту
-- и среднюю зарплату по должности.
-- Определить, во сколько раз средняя зарплата по департаменту
-- отличается от средней зарплаты по должности.
select e.employee_id,
       d.department_name as department,
       j.job_title as job,
       e.salary,
       avg(salary) over (partition by e.department_id) as avg_dep_salary,
       avg(salary) over (partition by e.job_id) as avg_job_salary,
       avg(salary) over (partition by e.department_id) /
        avg(salary) over (partition by e.job_id) as ratio
from employees e
join departments d on d.department_id = e.department_id
join jobs j on e.job_id = j.job_id;

-- Вывести список сотрудников, получающих минимальную зарплату по департаменту.
-- Если в каком-либо департаменте несколько сотрудников получают минимальную
-- зарплату, вывести того, чья фамилия идет раньше по алфавиту.
with ranked_employees as (
  select
    e.employee_id,
    e.last_name,
    e.salary,
    d.department_name,
    row_number() over (
      partition by e.department_id
      order by e.salary, e.last_name
    ) as rn
  from employees e
  join public.departments d on e.department_id = d.department_id
)
select employee_id, last_name, salary, department_name
from ranked_employees
where rn = 1;

-- На основе таблицы employees создать таблицу scores c результатами соревнований
-- со следующим маппингом:
-- employee_id -> man_id,
-- department_id -> division,
-- salary -> score.
-- Вывести список людей, занявших первые 3 места в каждом дивизионе
-- (т.е. занявших три позиции с максимальным количеством очков).
with ranked_employees as (
    select
        e.employee_id as man_id,
        e.department_id as division,
        e.salary as score,
        row_number() over (
            partition by department_id
            order by e.salary desc, e.department_id
            ) as rn
    from employees e
)
select re.man_id, re.division, re.score
from ranked_employees re
where rn <= 3;

-- Отсортировать список сотрудников по фамилиям и разбить на 5
-- по возможности равных групп. Для каждого сотрудника вывести
-- разницу между его зарплатой и средней зарплатой по группе.
with grouped_employees as (
  select
    e.employee_id,
    e.last_name,
    e.salary,
    ntile(5) over (order by e.last_name) as group_id
  from employees e
),
avg_salary_by_group as (
  select
    group_id,
    avg(salary) as avg_salary
  from grouped_employees
  group by group_id
)
select g.employee_id, g.last_name, g.salary, g.group_id,
  g.salary - a.avg_salary as salary_diff
from grouped_employees g
join avg_salary_by_group a on g.group_id = a.group_id
order by g.group_id, g.last_name;

-- Для каждого сотрудника посчитать количество сотрудников, принятых на работу
-- в период ± 1 год от даты его принятия на работу, а также количество сотрудников,
-- принятых позже данного сотрудника, но в этом же году.
-- Если два сотрудника приняты в один день, считать принятым позже
-- сотрудника с большим employee_id.
select employee_id, hire_date,
    count(*) over(
        order by hire_date
        range between interval '1 year' preceding
            and interval '1 year' following) - 1 as hires_in_range,
    count(*) over (
        partition by extract(year from hire_date)
        order by hire_date, employee_id
        rows between current row and unbounded following) - 1 as later_hires_in_year
from employees
order by hire_date, employee_id;
