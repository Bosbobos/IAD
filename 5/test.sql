select book.author, count(*)
from book
group by author;

select book.title, book.author
from book
order by author;

select book.author, count(*)
from book
group by author
order by count(*);

select book.pages_num from book
order by pages_num desc;
select avg(book.pages_num) from book;

select reader_nr, b.author from borrowing
join book b on borrowing.isbn = b.isbn;

select isbn, count(*) from copy
group by isbn
order by count(*) desc ;

select title from book
where author = 'Марк Твен';

with book_counts as (
    select pub_year,
           count(*) as books_in_year
    from book
    group by pub_year
    order by pub_year
)
select * from book_counts;

select * from book;

INSERT INTO book (isbn, title)
VALUES (123456, '123456');


DELETE FROM book
WHERE isbn = '123456';

selec