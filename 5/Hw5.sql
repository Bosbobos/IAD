-- Вывести все названия (Title) книг (Book) вместе
-- с названиями (PubName) их издателей (Publisher)
select title, pub_name from book;

-- Вывести ISBN книги/всех книг (Book) с максимальным количеством страниц (PagesNum)
select isbn from book b
where pages_num =
      (select max(pages_num)
      from book);



-- Какие авторы (Author) написали больше пяти книг (Book)?
select book.author from book
group by author
having count(*) > 5;

-- Вывести ISBN всех книг (Book), количество страниц (PagesNum) больше,
-- чем в два раза больше среднего количества страниц во всех книгах
select book.isbn from book
where pages_num > 2 * (select avg(pages_num)
                       from book);

-- Вывести категории, в которых есть подкатегории.
select distinct parent_cat from category
where parent_cat is not null;

-- Вывести имена всех авторов (Author), написавших больше всех книг.
-- Считать имена уникальными.
select book.author from book
group by author
having count(*) = (select max(book_count)
                   from (select count(*) as book_count
                         from book b
                         group by author) as counts);

-- Вывести номера читателей (ReaderNr),
-- которые брали (Borrowing) все книги (Book, не Copy) Марка Твена.
with twain_books as (
    select isbn
    from book
    where author = 'Марк Твен'
),
readers_borrowing as (
    select distinct reader_nr, isbn
    from borrowing
)
select rb.reader_nr
from readers_borrowing rb
join twain_books tb on rb.isbn = tb.isbn
group by rb.reader_nr
having count(distinct rb.isbn) = (select count(*) from twain_books);

-- У каких (ISBN) книг (Book) больше, чем одна копия (Copy)?
select isbn from copy
group by isbn
having count(*) > 1;

-- Вывести 10 самых старых (по PubYear) книг.
-- Если в самом древнем году 10 книг или больше, вывести их все.
-- Если нет, вывести, сколько есть, и дальше выводить все книги
-- из каждого предыдущего года, пока не наберется всего 10 или больше.
with book_counts as (
    select pub_year,
           count(*) as books_in_year
    from book
    group by pub_year
    order by pub_year
),
cumulative_counts as (
    select pub_year,
           books_in_year,
           sum(books_in_year) over (order by pub_year) as cumulative_books
    from book_counts
),
cutoff_year as (
    select pub_year
    from cumulative_counts
    where cumulative_books >= 10
    order by pub_year
    limit 1
)
select *
from book
where pub_year <= (select pub_year from cutoff_year)
order by pub_year, isbn;

-- Вывести все поддерево подкатегорий категории “Sports”.
WITH RECURSIVE subcategories AS (
    SELECT category_name, parent_cat
    FROM category
    WHERE category_name = 'Sports'

    UNION ALL

    SELECT c.*
    FROM category c
    JOIN subcategories sc ON c.parent_cat = sc.category_name
)
SELECT category_name
FROM subcategories;

-- Добавить в таблицу Borrowing запись про то,
-- что ‘John Johnson’ взял книгу c ISBN=123456 и CopyNumber=4.
INSERT INTO reader (first_name, last_name)
VALUES ('John', 'Johnson');

INSERT INTO book (isbn, title)
VALUES ('123456', '123456');

INSERT INTO copy (isbn, copy_number)
VALUES ('123456', 4);

INSERT INTO borrowing (reader_nr, isbn, copy_number)
VALUES (
    (SELECT id
        FROM reader
        WHERE first_name = 'John'
          AND last_name = 'Johnson'
        LIMIT 1),
    '123456',
    4
);

-- Удалить все книги с годом публикации больше, чем 2000.
BEGIN;

DELETE FROM copy
WHERE isbn IN (SELECT book.isbn
           FROM book
           WHERE pub_year > 2000);

DELETE FROM book
WHERE pub_year > 2000;

COMMIT;

-- Увеличить дату возврата на 30 дней (просто +30)
-- для всех книг в категории "Databases",
-- у которых эта дата > '01.01.2022'.
UPDATE borrowing
SET return_date = return_date + INTERVAL '30 days'
WHERE isbn IN (
    SELECT b.isbn
    FROM book b
    JOIN book_cat bc ON b.isbn = bc.isbn
    WHERE bc.category_name = 'Databases'
)
AND return_date > '2022-01-01';