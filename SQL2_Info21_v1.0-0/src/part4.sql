-- DROP DATABASE IF EXISTS "school_s21_part4";
-- CREATE DATABASE "school_s21_part4" ENCODING 'UTF8';

-- -------------------------------------   4.1
-- Создайте хранимую процедуру, которая, не уничтожая базу данных,
-- уничтожает все те таблицы в текущей базе данных, имена которых начинаются с фразы "Имя_таблицы".

CREATE OR REPLACE PROCEDURE pr_drop_tables(start_part_name_of_table varchar)
    LANGUAGE plpgsql AS
$$
DECLARE
    drop_command varchar;
    list         record;
BEGIN
    FOR list IN
        SELECT tablename t
        FROM pg_tables
        WHERE schemaname IN ('public')
          AND tablename ~ ('^' || $1 || '%*')
        LOOP
            BEGIN
                SELECT 'drop table if exists ' || list.t || ' cascade;' INTO drop_command;
                EXECUTE drop_command;
            END;
        END LOOP;
END
$$;

-- call pr_drop_tables('ve');

--------------------------------------------  4.2

-- Создайте хранимую процедуру с выходным параметром,
-- который выводит список имен и параметров всех скалярных пользовательских
-- SQL-функций в текущей базе данных. Не выводите имена функций без параметров.
-- Имена и список параметров должны быть в одной строке.
-- Выходной параметр возвращает количество найденных функций

CREATE OR REPLACE PROCEDURE pr_list_functions(count OUT int)
    LANGUAGE plpgsql AS
$$
DECLARE
    temp record;
BEGIN
    count = 0;
    FOR temp IN
        (SELECT i.routine_name AS functions, string_agg(p.parameter_name, ' ') AS parameters
         FROM information_schema.routines i
                  JOIN information_schema.parameters p
                       ON i.specific_name = p.specific_name
                           AND p.parameter_mode = 'IN'
         WHERE i.routine_type = 'FUNCTION'
           AND i.routine_schema = 'public'
         GROUP BY i.routine_name)
        LOOP
            RAISE NOTICE '%', temp;
            count = count + 1;
        END LOOP;

END;
$$;

-- call pr_list_functions(0);

------------------------------------------- 4.3

--  Создайте хранимую процедуру с выходным параметром,
-- которая уничтожает все триггеры SQL DDL в текущей базе данных.
-- Выходной параметр возвращает количество уничтоженных триггеров.

CREATE OR REPLACE PROCEDURE pr_drop_trifggers(OUT count int)
    LANGUAGE plpgsql AS
$$
DECLARE
    list     record;
    drop_row text;
BEGIN
    count = 0;
    FOR list IN (SELECT trigger_name, event_object_table
                 FROM information_schema.triggers
                 WHERE trigger_schema = 'public')
        LOOP
            drop_row = 'DROP TRIGGER ' || list.trigger_name ||
                       ' ON ' || list.event_object_table || ' CASCADE';
            EXECUTE drop_row;
            count = count + 1;
        END LOOP;
END
$$;

-- call pr_drop_trifggers(0);

------------------------------------------- 4.4

-- Создайте хранимую процедуру с входным параметром,
-- который выводит имена и описания типов объектов (только хранимых процедур и скалярных функций),
-- которые имеют строку, указанную параметром процедуры.

CREATE OR REPLACE PROCEDURE pr_list_proc_and_func(IN template_name text)
    LANGUAGE plpgsql AS
$$
DECLARE
    result  varchar;
    cursor1 refcursor;

BEGIN
    OPEN cursor1 FOR
        SELECT routine_name || ' ' || routine_type AS proc_and_func
        FROM (SELECT routines.routine_name, routines.routine_type
              FROM information_schema.routines
                       JOIN information_schema.parameters par ON routines.specific_name = par.specific_name
              WHERE (routines.routine_type = 'PROCEDURE'
                  OR routines.routine_type = 'FUNCTION')
                AND routines.specific_schema = 'public'
                AND routines.routine_definition LIKE '%' || template_name || '%'
              GROUP BY routines.routine_name, routine_type) func;
    LOOP
        FETCH cursor1 INTO result;
        EXIT WHEN NOT found;
        RAISE INFO '%', result;
    END LOOP;
    CLOSE cursor1;
END
$$;

-- call pr_list_proc_and_func('friends');
