-- CREATE STATEMENTS
create table professors
(
    id       serial primary key,
    name     text not null,
    surname  text not null,
    age      int  not null,
    birthday date not null,
    position text not null,
    boss_id  int references professors (id)
);

create table study_groups
(
    id      serial primary key,
    name    text not null unique,
    program text not null,
    year    int  not null
);

create table professor_groups
(
    professor_id int  not null references professors (id),
    group_id     int  not null references study_groups (id),
    subject      text not null,

    primary key (professor_id, group_id, subject)
);

insert into study_groups (name, program, year)
values ('БПИ205', 'Программная инженерия', 2020),
       ('БПИ206', 'Программная инженерия', 2020),
       ('БПИ2411', 'Программная инженерия', 2024),
       ('БПМИ231', 'Прикладная матетематика и информатика', 2023);

insert into professors (name, surname, age, birthday, position, boss_id)
values ('Иван', 'Аржанцев', 40, '01-01-1984', 'Декан', null),
       ('Евгений', 'Соколов', 35, '01-01-1989', 'Руководитель департамента', 1),
       ('Всеволод', 'Чернышев', 35, '01-01-1989', 'Доцент', 2),
       ('Иван', 'Иванов', 30, '01-01-1994', 'Доцент', 2),
       ('Петр', 'Иванов', 20, '01-01-2004', 'Ассистент', 4);
      
insert into professor_groups (professor_id, group_id, subject)
values (1, 1, 'Криптография'),
       (1, 2, 'Криптография'),
       (2, 3, 'Машинное обучение'),
       (1, 3, 'Алгебра'),
       (3, 3, 'Алгебра'),
       (3, 2, 'Алгебра'),
       (3, 1, 'Алгебра'),
       (4, 4, 'Математический анализ'),
       (4, 2, 'Дискретная математика');

-- GROUP BY
-- без группировки: повторяются значения
select professor_id
from professor_groups;
 
-- сгруппировали по professor_id
select professor_id
from professor_groups
group by professor_id;
 
 
-- пытаемся получить что то еще, логично получаем ошибку, потому что непонятно какой group_id вернуть, это не distinct
select professor_id, subject 
from professor_groups
group by professor_id;
 
-- так же как и в прошлом пункте частая ошибка, берем непогруппированные колонки
select *
from professor_groups
group by professor_id;
 
-- группировать можно сразу по нескольким колонкам
select professor_id, subject
from professor_groups
group by professor_id, subject;
 
-- Агрегатные функции
-- буквально агрегируют множество значений до одного
-- например вот тут, соберем все группы в массив
select professor_id, array_agg(subject)
from professor_groups
group by professor_id;
 
-- в select запросе с группировкой могут присутсвовать либо группируемые поля, либо агрегаты над остальными полями (и не только)
-- например count(1) - агрегирующая функция которая возвращает количество схлопнутых строк
select professor_id, array_agg(subject), count(*)
from professor_groups
group by professor_id;
 
-- какие еще моугт быть агрегирующие функции? куча https://www.postgresql.org/docs/current/functions-aggregate.html
-- основные примеры:
select professor_id,
       array_agg(group_id),
       count(group_id),
       min(group_id),
       max(group_id),
       avg(group_id + 0.5),
       json_agg(group_id),
       string_agg(group_id::text, '|'),
       sum(group_id)
-- и много-много других
from professor_groups
group by professor_id;
 
 
-- агрегатные функции могут быть по модифицированным колонкам/произвольным выражениям
select professor_id, array_agg(lower(p.name)), sum(100)
from professor_groups
         join public.professors p on p.id = professor_groups.professor_id
group by professor_id;
 
-- а так же сама группировка может быть по модифицированным колонкам/произвольным выражениям
-- так получим ошибку
select p.position
from professors p
group by lower(p.position);
 
-- а тут все ок
select lower(p.position)
from professors p
group by lower(p.position);
 
-- а вот например группировка по результату конкатенации
select lower(p.position), p.name || ' ' || p.surname, count(1)
from professor_groups
         join public.professors p on p.id = professor_groups.professor_id
group by lower(p.position), p.name || ' ' || p.surname;
 
-- или вообще можно сгруппировать по константе и таким образом сгруппировать все строки в одну
select count(*)
from professor_groups
group by 123 + 123;
 
 
-- такое же можно проворачивать и без group by, просто прописав агрегатную функцию
select avg(age)
from professors p;
 
 
-- HAVING
-- а что если мы хотим пофильтровать уже после агрегации
-- например хотим получить всех профессоров которые ведут больше 1 пары: попробуем написать в where и получим ошибку
select professor_id, count(1)
from professor_groups
where count(*) > 1 -- ошибка
group by professor_id;
 
-- логично, where идет до group by и не может использовать результаты агрегирования, как тогда делать? having!
select professor_id, count(1)
from professor_groups
group by professor_id
having count(1) > 1;
 
-- так же в having можно писать условия на сами колонки группировки
select professor_id, count(1)
from professor_groups
group by professor_id
having professor_id > 2
   and count(1) > 1;
 
-- как думаете, какой вариант лучше?
select professor_id, count(1)
from professor_groups
where professor_id > 2
group by professor_id
having count(1) > 1;
-- (формально этот, так как не делаем сначала лишнюю группировку а сразу фильтруем,
-- но на самом деле скорее всего оптимизатор запросов в бд сведет их к одному и тому же реальному запросу)
 
 
-- CTE/Common Table Expressions/With queries
-- просто позволяет завести временные именованые таблицы для запроса и далее их использовать
 
-- заведем таблицу всех пишных групп и просто получим ее
with pi_groups as (select *
                   from study_groups
                   where program = 'Программная инженерия')
select *
from pi_groups;
 
-- выберем все professor_groups
with pi_groups as (select *
                   from study_groups
                   where program = 'Программная инженерия')
select *
from professor_groups
where group_id = any (select id from pi_groups);
 
-- можно делать несколько таких таблиц
-- например вот тут получим всех профессоров которые ведут пары на пи и не ведут на пми
with pi_groups as (select * from study_groups where program = 'Программная инженерия'),
     pmi_groups as (select * from study_groups where program = 'Прикладная матетематика и информатика')
select distinct p.name, p.surname
from professors p
join professor_groups pg on p.id = pg.professor_id
where pg.group_id = any (select id from pi_groups)
	and not pg.group_id = any (select id from pmi_groups);

-- Альтернатива
with pi_groups as (select * from study_groups where program = 'Программная инженерия'),
     pmi_groups as (select * from study_groups where program = 'Прикладная матетематика и информатика')
select *
from professors p
where exists (select *
              from professor_groups pg
              where pg.professor_id = p.id
                and pg.group_id = any (select id from pi_groups))
  and not exists (select *
                  from professor_groups pg
                  where pg.professor_id = p.id
                    and pg.group_id = any (select id from pmi_groups));
 
 
-- короткое отступление про union/union all/except
-- можем объединить результаты запросов если схемы результатов совпадают
 
                   
-- так можно
select 1
union
select 2;

-- так нельзя
select 1
union
select 2, 3;
 
-- так можно, но union всегда проверяет на уникальность, как в реляционной алгебре
select 1
union
select 1;
 
select 1, 2
union
select 1, 3;
 
-- если нужны дубликаты, используем union all, он эффективнее так как не делает проверок на уникальность строк
select 1
union all
select 1;
 
-- можно удалять определенные строки из результата
select 1
union all
select 2
except all
select 1;
 
-- или брать пересечение двух запросов
values (1),
       (2)
intersect
values (2),
       (3);
 
select id
from professors
where id > 2
intersect all
select id
from professors
where id < 4;
 
-- union, except и intersect есть в all и обычном варианте, все работает аналогично как показывал с union
 
-- для чего это все: хотим рекурсию!
-- есть дерево сотрудников с руководителями и подчиненными, хотим получить всех подчиненных определенного человека
-- как устроена любая рекурсия? есть база рекурсии, шаг рекурсии и условие остановки
select *
from professors p;

with recursive subq as
                   (select *
                    from professors
                    where id = 2 -- база рекурсии, от кого запускаем поиск
                    
                    union ALL
                    
                    select p.*
                    from subq s
                             join professors p -- шаг рекурсии
                                  on p.boss_id = s.id -- шаг рекурсии + условие остановки
                   )
select *
from subq;
 
-- можем попробовать получить такое дерево по всем сотрудникам получим строки вперемешку, как отличать одну от другой?
with recursive subq as
                   (select *
                    from professors
                    
                    union ALL
                    
                    select p.*
                    from subq s
                             join professors p -- шаг рекурсии
                                  on p.boss_id = s.id -- шаг рекурсии + условие остановки
                   )
select *
from subq;
 
-- можно передавать из базы рекурсии поле, и использовать его как константу на всех шагах рекурсии, например тут передаем профессора, от которого начали поиск
with recursive subq as
                   (select id root_professor, *
                    from professors
                    
                    union ALL
                    
                    select s.root_professor, p.*
                    from subq s
                             join professors p -- шаг рекурсии
                                  on p.boss_id = s.id -- шаг рекурсии + условие остановки
                   )
select *
from subq
order by root_professor;
 
-- а если еще и хотим знать глубину на которой сотрудник в дереве? тоже можем передавать при шаге рекурсии
with recursive subq as
                   (select id root_professor, 1 as depth, *
                    from professors
                    
                    union ALL
                    
                    select s.root_professor, s.depth + 1 as depth, p.*
                    from subq s
                             join professors p -- шаг рекурсии
                                  on p.boss_id = s.id -- шаг рекурсии + условие остановки
                   )
select *
from subq
order by root_professor;