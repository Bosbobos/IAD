-- Data manipulation

create table students
(
  	id     int,
    name     text,
    gpa numeric default 5,
    age int
);

-- Для вставки обычно используем литералы. Нужно знать порядок
INSERT INTO students VALUES (1, 'Polina', 8.1, 21);

-- Упадет, тк порядок не тот (типы данных не сошлись)
INSERT INTO students VALUES (8.1, 2, 'Not Polina', 10);

-- Явно указываем колонки
INSERT INTO students (gpa, id, name, age)
VALUES (8.1, 2, 'Not Polina', 5);

-- Можно опускать колонки, будут подставляться дефолтные значения
INSERT INTO students (id, name)
VALUES (3, 'Some student');

select * from students p;

-- Можно указать дефолт явно
INSERT INTO students (id, name, gpa, age)
VALUES (4, 'Who', default, default);

select * from students p;

-- Можно вообще все вставить по дефолту :)
INSERT INTO students DEFAULT VALUES;
select * from students p;

-- Можно несколько строк вставить одной командой
INSERT INTO students (id, name)
values
    (1, 'Lev'),
    (2, 'Yana'),
    (3, 'Alisa');
select * from students p;

-- Можно вставить результат селекта
create table other_students
(
  	id     int,
    name     text
);
INSERT INTO other_students (id, name)
values
    (9, 'Zahar'),
    (10, 'Platon'),
    (11, 'Maxim');
   
insert into students (id, name)
	select id, name
		from other_students os
		where os.id > 9;


select * from students p;

-- UPDATE. Самый простой
update students
set age = 22
where id = 3;

select * from students p;

-- Можно обновлять сразу несколько значений
update students 
set gpa = 10, age = gpa 
where id = 1;

select * from students p;

-- Значение необязательно скаляр, это может быть выражение
update students 
set gpa = gpa * 1.1;

select * from students s;

-- Значение необязательно скаляр, это может быть выражение
update students 
set gpa = gpa * 1.1
returning name, gpa as new_gpa;

-- Update с использованием других таблиц
create table course_marks (
	subject name,
	mark int,
	name text
);

insert into course_marks (subject, mark, name)
values ('Algebra', 5, 'Some student'),
		('Algebra', 7, 'Polina');
	
-- FROM - работает как join. Обновит только пересечения
UPDATE students s SET gpa = mark
FROM course_marks cm WHERE cm.name = s.name
returning *;
	
-- Подзапрос. Обновит все, поскольку нет where, где нет данных стало null
UPDATE students s SET gpa = 
	(select mark from course_marks cm
	WHERE cm.name = s.name)
returning *;

-- Убрали обновление всего
UPDATE students s SET gpa = 
	(select mark from course_marks cm
	WHERE cm.name = s.name)
where s.name in (
	select name from course_marks
)
returning *;

-- А что если у нас несколько оценок у одного студента?
-- Для insert тоже есть returning
insert into course_marks (subject, mark, name)
values ('Databases', 10, 'Some student')
returning *;

select * from course_marks;

-- FROM. Отработает, результат можно считать недетерминированным
UPDATE students s SET gpa = mark
FROM course_marks cm WHERE cm.name = s.name
returning *;
	
-- Подзапрос. Упадет
UPDATE students s SET gpa = 
	(select mark from course_marks cm
	WHERE cm.name = s.name)
returning *;

-- Результат можно агрегировать
UPDATE students s SET gpa = 
	(select avg(mark) from course_marks cm
	WHERE cm.name = s.name)
returning *;

-- Delete. Простейший
delete from students
where id = 2;

select * from students;

-- Delete. Есть returning
delete from students
where id = 1
returning *;

-- Удаляем все
delete from other_students;
select * from other_students;

-- Удаляем с помощью Join
delete from students s
using course_marks cm
where s.name = cm.name
returning *;

select * from students;
