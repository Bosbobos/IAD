create table professors
(
    id       serial primary key,
    name     text not null,
    surname  text not null,
    age      int  not null,
    birthday date not null,
    position text not null,
    boss_id  int references professors
);

create table study_groups
(
    id      serial primary key,
    name    text not null unique,
    program text not null,
    year    int  not null
);

-- Убрали указание колонки для FK - по умолчанию взялся PK
-- Not null констрейнт для колонок PK необязательно указывать
-- ON DELETE RESTRICT
-- ON Delete Cascade
create table professor_groups
(
    professor_id int  references professors ON DELETE RESTRICT,
    group_id     int  references study_groups ON DELETE CASCADE,
    subject      text,

    primary key (professor_id, group_id, subject)
);

insert into study_groups (name, program, year)
values ('БПИ205', 'Программная инженерия', 2020),
       ('БПИ206', 'Программная инженерия', 2020),
       ('БПИ2411', 'Программная инженерия', 2024),
       ('БПМИ231', 'Прикладная матетематика и информатика', 2023);

insert into professors (name, surname, age, birthday, position, boss_id)
values ('Всеволод', 'Чернышев', 35, '01-01-1989', 'Доцент', null),
		('Иван', 'Иванов', 35, '01-01-1989', 'Доцент', null);

insert into professor_groups (professor_id, group_id, subject)
values (1, 3, 'Алгебра'),
       (1, 2, 'Алгебра'),
       (1, 1, 'Алгебра');
      
select p.name, p.surname, sg.name, subject 
from professor_groups pg
join professors p on pg.professor_id = p.id
join study_groups sg on sg.id = pg.group_id 
      
-- Удаляем профессора. Упало
DELETE FROM professors
where id = 1;

-- Удаляем группу. Отработало
delete from study_groups
where name = 'БПИ205'

-- Заменяем на NO ACTION
alter table professor_groups 
drop constraint professor_groups_professor_id_fkey;

alter table professor_groups 
add constraint professor_groups_professor_id_fkey
foreign key (professor_id) references professors
on delete no action
deferrable INITIALLY deferred;

-- Удаляем профессора. Опять упало
DELETE FROM professors
where id = 1;

-- No action с отложенной проверкой в транзакции
BEGIN;

DELETE FROM professors
WHERE id = 1;

UPDATE professor_groups
SET professor_id = 2
WHERE professor_id = 1;

COMMIT;


-- ON DELETE SET NULL
drop table professor_groups;
drop table professors;

create table professors
(
    id       serial primary key,
    name     text not null,
    surname  text not null,
    age      int  not null,
    birthday date not null,
    position text not null,
    boss_id  int references professors (id) on delete set null 
);

insert into professors (name, surname, age, birthday, position, boss_id)
values ('Иван', 'Аржанцев', 40, '01-01-1984', 'Декан', null),
       ('Евгений', 'Соколов', 35, '01-01-1989', 'Руководитель департамента', 1),
       ('Всеволод', 'Чернышев', 35, '01-01-1989', 'Доцент', 2),
       ('Иван', 'Иванов', 30, '01-01-1994', 'Доцент', 2),
       ('Петр', 'Иванов', 20, '01-01-2004', 'Ассистент', 4);
       
delete from professors 
where id = 1;

select * from professors;

-- Аналогично set default
-- Аналогично on delete есть on update
