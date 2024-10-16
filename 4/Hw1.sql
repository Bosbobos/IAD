-- Да, я думаю, что джойны кусаются (ладно, я попробую с ними подружиться (в следующей работе!!))
-- А пока наслаждаемся вложенными селектами (я сам в ужасе, честно)

-- Все фамилии (LastName) читателей (Reader) из Москвы
select last_name from reader
where address = 'Москва';

-- Все названия (Title) и авторов (Author) книг (Books), опубликованных
-- издателями (Publisher) научной или справочной литературы
-- (pubKind либо 'Science', либо 'Reference')
select title, author from book
where pub_name in (
    select pub_name
    from publisher
    where pub_kind in ('Science', 'Reference')
    );

-- Все названия (Title) и авторов (Author) книг (Books), которые брал Иван Иванов
select title, author
from book
where isbn in (
    select isbn
    from borrowing
    where reader_nr in (select id
                       from reader
                       where last_name = 'Иванов'
                         and first_name = 'Иван')
    );

-- Все идентификаторы (ISBN) книг (Book), относящихся к категории "Mountains",
-- но не относящихся к категории "Travel". Подкатегории не учитывать.
select isbn
from book
where isbn in (
    select isbn
    from book_cat
    where category_name = 'Mountains'
    and category_name != 'Travel'
    );

-- Все фамилии и имена читателей, которые вернули
-- хотя бы одну книгу (Borrowing.ReturnDate is not null)
select first_name, last_name
from reader
where id in (
    select reader_nr
    from borrowing
    where return_date is not null
    );

-- Все фамилии и имена читателей, которые брали (Borrowing)
-- хотя бы одну книгу (Book), которую брал Иван Иванов.
-- Ответ не должен содержать самого Ивана Иванова.
select first_name, last_name
from reader r
where id in (
    select reader_nr
    from borrowing b
    where b.reader_nr in (
        select reader_nr
        from borrowing br
        where br.isbn in (
            select br.isbn
            from borrowing br
            where br.reader_nr in (
                select re.id
                from reader re
                where re.first_name = 'Иван'
                and re.last_name = 'Иванов'
                )
            )
        )
    )
and (r.first_name != 'Иван'
      or r.last_name != 'Иванов');
