-- CHECK constraint
create table professors
(
    id       serial primary key,
    name     text not null,
    salary   numeric CHECK (salary > 0)
);

-- Упадет
insert into professors (name, salary)
values ('P1', -1);


-- OK
insert into professors (name, salary)
values ('P1', null);

drop table professors;

-- Name for constraint
create table professors
(
    id       serial primary key,
    name     text not null,
    surname  text not null,
    salary   numeric not null constraint positive_salary check (salary > 0)
);

-- CHECK constraint for two cols
create table professors
(
    id       serial primary key,
    name     text not null,
    salary   numeric CHECK (salary > 0),
    salary_no_taxes numeric CHECK (salary_no_taxes > 0),
    CHECK (salary  > salary_no_taxes)
);

select * from reader;