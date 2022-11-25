----------------------------------------------------- 3.1
-- Напишите функцию, которая возвращает таблицу переданных точек в более удобочитаемой форме

CREATE OR REPLACE FUNCTION fnc_transfered_points()
    RETURNS table
            (
                peer1        varchar,
                peer2        varchar,
                pointsamount bigint
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT checkingpeer,
               checkedpeer,
               ((SELECT coalesce(sum(t2.pointsamount), 0)
                 FROM transferredpoints t2
                 WHERE t2.checkingpeer = t1.checkingpeer
                   AND t2.checkedpeer = t1.checkedpeer) -
                (SELECT coalesce(sum(t3.pointsamount), 0)
                 FROM transferredpoints t3
                 WHERE t3.checkedpeer = t1.checkingpeer
                   AND t3.checkingpeer = t1.checkedpeer))::bigint
        FROM transferredpoints t1
        WHERE t1.checkingpeer NOT IN (SELECT checkedpeer
                                      FROM transferredpoints
                                      WHERE checkingpeer = t1.checkedpeer);
END;
$$;

-- select * from fnc_transfered_points();

------------------------------------------------------ 3.2
-- Напишите функцию, которая возвращает таблицу следующего вида:
--     имя пользователя, название проверенной задачи, количество полученных XP

CREATE OR REPLACE FUNCTION fnc_success_checks()
    RETURNS table
            (
                peer varchar,
                task varchar,
                xp   bigint
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT c.peer, t.title, x.xpamount
        FROM checks c
                 JOIN tasks t ON c.task = t.title
                 JOIN xp x ON c.id = x."Check";

END;
$$;

-- select * from fnc_success_checks();

-----------------------------------------  3.3
--  Напишите функцию, которая находит сверстников, которые не покидали кампус в течение целого дня

CREATE OR REPLACE FUNCTION fnc_no_left_campus(day date) RETURNS setof record
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN QUERY
        WITH list1 AS
                 (SELECT *
                  FROM timetracking
                  WHERE daterange((SELECT min(date) FROM timetracking), day, '[]') @> date
                    AND peer NOT IN (SELECT peer
                                     FROM timetracking
                                     WHERE state IN (1, 2)
                                       AND date = day
                                       AND time != '00:00:00')
                  ORDER BY date)
        SELECT peer
        FROM list1
        GROUP BY peer
        HAVING sum(state) % 3. = 1;
END
$$;


-- select * from fnc_no_left_campus('2022-06-07') as (peers varchar);
-- select * from fnc_no_left_campus('2022-09-09') as (peers varchar);

----------------------------------------------------- 3.4
-- Найдите процент успешных и неудачных проверок за все время

CREATE OR REPLACE PROCEDURE pr_percentge_task(successfulchecks OUT bigint, unsuccessfulchecks OUT bigint)
    LANGUAGE plpgsql AS
$$
DECLARE
    one_     numeric;
    success_ numeric;
BEGIN
    SELECT count(*) INTO success_ FROM xp;
    SELECT count(*) / 100. INTO one_ FROM checks;
    SELECT success_ / one_ INTO success_;

    SELECT success_ INTO successfulchecks;
    SELECT 100 - success_ INTO unsuccessfulchecks;

END;
$$;

-- call pr_percentge_task(0, 0);

---------------------------------------------  3.5
-- Вычислите изменение количества баллов каждого пира, используя таблицу TransferredPoints


CREATE OR REPLACE FUNCTION fnc_peer_xp_checking()
    RETURNS table
            (
                checkingpeer varchar,
                pointsamount bigint
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT p2.nickname, coalesce(sum(t.pointsamount)::bigint, 0) AS p
        FROM transferredpoints t
                 RIGHT JOIN peers p2 ON p2.nickname = t.checkingpeer
        GROUP BY p2.nickname;
END;
$$;

CREATE OR REPLACE FUNCTION fnc_peer_xp_checked()
    RETURNS table
            (
                checkedpeer  varchar,
                pointsamount bigint
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT p2.nickname, coalesce(sum(t.pointsamount)::bigint, 0) AS p
        FROM transferredpoints t
                 RIGHT JOIN peers p2 ON p2.nickname = t.checkedpeer
        GROUP BY p2.nickname;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_peer_xp_3_5(peer INOUT refcursor)
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN peer FOR
        SELECT c.checkedpeer, (ch.pointsamount - c.pointsamount) AS pointschange
        FROM (SELECT * FROM fnc_peer_xp_checking()) ch
                 JOIN (SELECT * FROM fnc_peer_xp_checked()) c ON c.checkedpeer = ch.checkingpeer
        ORDER BY pointschange DESC;
END;
$$;

-- BEGIN;
--     call pr_peer_xp_3_5('a');
--     FETCH ALL IN "a";
-- END;

---------------------------------------------  3.6
-- Вычислите изменение количества баллов каждого пира, используя 3.1

CREATE OR REPLACE FUNCTION fnc_peer_xp_checking_from_3_1()
    RETURNS table
            (
                checkingpeer varchar,
                pointsamount bigint
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT p2.nickname, coalesce(sum(t.pointsamount)::bigint, 0) AS p
        FROM (SELECT * FROM fnc_transfered_points()) t
                 RIGHT JOIN peers p2 ON p2.nickname = t.peer1
        GROUP BY p2.nickname;
END;
$$;

CREATE OR REPLACE FUNCTION fnc_peer_xp_checked_from_3_1()
    RETURNS table
            (
                checkedpeer  varchar,
                pointsamount bigint
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT p2.nickname, coalesce(sum(t.pointsamount)::bigint, 0) AS p
        FROM (SELECT * FROM fnc_transfered_points()) t
                 RIGHT JOIN peers p2 ON p2.nickname = t.peer2
        GROUP BY p2.nickname;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_peer_xp_3_6(peer INOUT refcursor)
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN peer FOR
        SELECT c.checkedpeer, (ch.pointsamount - c.pointsamount) AS pointschange
        FROM (SELECT * FROM fnc_peer_xp_checking_from_3_1()) ch
                 JOIN (SELECT * FROM fnc_peer_xp_checked_from_3_1()) c ON c.checkedpeer = ch.checkingpeer
        ORDER BY pointschange DESC;
END;
$$;

-- BEGIN;
--     call pr_peer_xp_3_6('a');
--     FETCH ALL IN "a";
-- END;


---------------------------------------------  3.7
-- Определить самое часто проверяемое задание за каждый день

CREATE OR REPLACE FUNCTION fnc_oft_review_task_in_day(IN every_day date)
    RETURNS table
            (
                task_name varchar
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    count_task int;
BEGIN
    SELECT count(task) AS ct
    INTO count_task
    FROM checks
    WHERE date = every_day
    GROUP BY task
    ORDER BY ct DESC
    LIMIT (1);

    RETURN QUERY
        SELECT task
        FROM checks
        WHERE date = every_day
        GROUP BY task
        HAVING count(task) = count_task;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_oft_review_task(result INOUT refcursor)
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN result FOR
        SELECT DISTINCT date AS day, fnc_oft_review_task_in_day(date) AS task
        FROM checks
        ORDER BY date DESC;
END;
$$;

-- BEGIN;
--     call pr_oft_review_task('result');
--     FETCH ALL IN "result";
-- END;


---------------------------------------------  3.8
-- Определить длительность последней P2P проверки

CREATE OR REPLACE PROCEDURE pr_duration_last_check_p2p(result INOUT refcursor)
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN result FOR
        WITH temp AS
                 (SELECT *
                  FROM p2p
                  WHERE "Check" IN (SELECT "Check"
                                    FROM p2p
                                    WHERE time IN (SELECT max(time) FROM p2p WHERE state != 'Start')))
        SELECT DISTINCT (SELECT time FROM temp WHERE state != 'Start') -
                        (SELECT time FROM temp WHERE state = 'Start')
                            AS duration_last_check
        FROM temp;
END;
$$;

-- BEGIN;
--     call pr_duration_lASt_check_p2p('result');
--     FETCH ALL IN "result";
-- END;

---------------------------------------------  3.9
-- Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания

CREATE OR REPLACE FUNCTION fnc_get_block_end_date(IN name_block_ varchar)
    RETURNS varchar
    LANGUAGE plpgsql AS
$$
DECLARE
    res varchar;
BEGIN
    SELECT title
    INTO res
    FROM tasks
    WHERE title LIKE (name_block_ || '_')
    ORDER BY title DESC
    LIMIT (1);
    RETURN res;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_completed_block_of_tasks(IN name_block_ varchar,
                                                        result INOUT refcursor)
    LANGUAGE plpgsql AS
$$
DECLARE
    final_task varchar;
BEGIN
    SELECT fnc_get_block_end_date(name_block_) INTO final_task;

    OPEN result FOR
        SELECT peer, date AS day
        FROM checks
        WHERE task = final_task
        ORDER BY day;
END;
$$;

-- BEGIN;
--     call pr_completed_block_of_tasks('CPP', 'result');
--     FETCH ALL IN "result";
-- END;

---------------------------------------------  3.10
-- Определить, к какому пиру стоит идти на проверку каждому обучающемуся

CREATE OR REPLACE FUNCTION fnc_amount_of_recommendation(peer_ varchar) RETURNS varchar
    LANGUAGE plpgsql AS
$$
DECLARE
    result varchar;
BEGIN
    SELECT r.recommendedpeer, peer, count(recommendedpeer) AS amount_of_recomendation
    INTO result
    FROM ((SELECT peer2 AS peer_friend
           FROM peers
                    JOIN friends ON peers.nickname = friends.peer2
           WHERE peer1 = peer_)
          UNION ALL
          (SELECT peer1 AS peer_friend
           FROM peers
                    JOIN friends ON peers.nickname = friends.peer1
           WHERE peer2 = peer_)) AS temp
             JOIN recommendations r ON r.peer = peer_friend
    WHERE recommendedpeer != peer_
    GROUP BY r.recommendedpeer, peer
    ORDER BY 2 DESC
    LIMIT (1);
    RETURN result;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_find_best_peer(result INOUT refcursor)
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN result FOR
        SELECT nickname, fnc_amount_of_recommendation(nickname) AS recomended_peer
        FROM peers;
END;
$$;

-- BEGIN;
--     call pr_find_best_peer('result');
--     FETCH ALL IN "result";
-- END;

----------------------------------------------  3.11
-- Определите процент сверстников, которые:
-- Начат блок 1
-- Запущен блок 2
-- Запустил оба
-- Не запустили ни один из них

CREATE OR REPLACE PROCEDURE pr_start_blocks_3_11(in_block1 varchar, in_block2 varchar, res INOUT refcursor)
    LANGUAGE plpgsql AS
$$
DECLARE
    block1_count        int;
    block2_count        int;
    block1_block2_count int;
    not_started         int;
    count_peers         int;
BEGIN
    SELECT count(*)
    INTO block1_count
    FROM (SELECT DISTINCT ON (c.peer) c.peer
          FROM xp
                   JOIN checks c ON c.id = xp."Check" AND c.task LIKE in_block1 || '%') f1;

    SELECT count(*)
    INTO block2_count
    FROM (SELECT DISTINCT ON (c.peer) c.peer
          FROM xp
                   JOIN checks c ON c.id = xp."Check" AND c.task ~ (in_block2 || '[1-4]{1}')) f2;

    SELECT count(*)
    INTO block1_block2_count
    FROM (SELECT DISTINCT ON (c.peer) c.peer
          FROM xp
                   JOIN checks c ON c.id = xp."Check" AND c.task LIKE in_block1 || '%'
          INTERSECT
          SELECT DISTINCT ON (c.peer) c.peer
          FROM xp
                   JOIN checks c ON c.id = xp."Check" AND c.task ~ (in_block2 || '[1-4]{1}')) f2;

    SELECT count(*)
    INTO not_started
    FROM (SELECT nickname
          FROM peers
          EXCEPT
          SELECT DISTINCT peer
          FROM checks) p1;

    SELECT count(*) INTO count_peers FROM peers;

    OPEN res FOR SELECT round(block1_count * 100 / count_peers)              AS startedblock1,
                        100 - round(block1_count * 100 / count_peers)        AS startedblock2,
                        round(block1_block2_count * 100 / count_peers)       AS startedbothblocks,
                        100 - round(block1_block2_count * 100 / count_peers) AS didntstartanyblock;
END
$$;

-- BEGIN;
-- CALL pr_start_blocks_3_11('CPP', 'C', 'cur');
-- FETCH ALL IN "cur";
-- END;

---------------------------------------------  3.12
-- Определить N пиров с наибольшим числом друзей

CREATE OR REPLACE PROCEDURE pr_amount_of_friends(n int, result INOUT refcursor)
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN result FOR
        SELECT peer2 AS peer, sum(num) AS friends
        FROM ((SELECT peer2, count(peer2) AS num
               FROM friends
               GROUP BY peer2)
              UNION ALL
              (SELECT peer1, count(peer1) AS num
               FROM friends
               GROUP BY peer1)) AS num
        GROUP BY peer2
        ORDER BY 2 DESC, 1
        LIMIT (n);
END;
$$;

-- BEGIN;
--     call pr_amount_of_friends(3, 'result');
--     FETCH ALL IN "result";
-- END;

---------------------------------------------  3.13
-- Определить процент пиров, которые когда-либо успешно проходили проверку в свой день рождения
-- Также определите процент пиров, которые хоть раз проваливали проверку в свой день рождения

CREATE OR REPLACE FUNCTION fnc_amount_of_check_on_birthday(IN actual_state check_status)
    RETURNS int
    LANGUAGE plpgsql
AS
$$
DECLARE
    res int;
BEGIN
    SELECT count(*)
    INTO res
    FROM (SELECT DISTINCT peer
          FROM checks
                   JOIN p2p ON checks.id = p2p."Check"
                   FULL JOIN verter ON checks.id = verter."Check"
                   JOIN peers ON peers.nickname = checks.peer
          WHERE extract(DAY FROM peers.birthday) = extract(DAY FROM checks.date)
            AND extract(MONTH FROM peers.birthday) = extract(MONTH FROM checks.date)
--             AND p2p.state = 'Failure'
            AND ((verter.state = actual_state OR verter.state IS NULL)
              OR (p2p.state = actual_state AND (verter.state = actual_state OR verter.state IS NULL))))
             AS temp;
    RETURN res;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_percent_check_on_birthday(IN result refcursor = 'pr_result')
    LANGUAGE plpgsql AS
$$
DECLARE
    amount_birthday_peers int;
BEGIN
    SELECT fnc_amount_of_check_on_birthday('Start') INTO amount_birthday_peers;

    RAISE NOTICE 'amount_birthday_peers = %', amount_birthday_peers;

    IF (amount_birthday_peers > 0) THEN
        OPEN result FOR
            SELECT round(fnc_amount_of_check_on_birthday('Success') * 100 / amount_birthday_peers) AS successful_checks,
                   round(fnc_amount_of_check_on_birthday('Failure') * 100 / amount_birthday_peers) AS unsuccessful_checks;
    END IF;
END;
$$;

-- BEGIN;
--     call pr_percent_check_on_birthday();
--     FETCH ALL IN pr_result;
-- END;


-- created by victoriv
--------------------------------------------- task 3.14
--  Определите общее количество опыта, полученного каждым коллегой

CREATE OR REPLACE FUNCTION get_xp_all_peers()
    RETURNS table
            (
                peers varchar,
                xp    numeric
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT temp.peer, sum(maxxp)
        FROM (SELECT DISTINCT checks.peer, checks.task, tasks.maxxp
              FROM p2p
                       JOIN checks ON p2p."Check" = checks.id
                       JOIN tasks ON checks.task = tasks.title
              WHERE p2p.state = 'Success') AS temp
        GROUP BY temp.peer
        ORDER BY 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pd_get_xp_everyone(res_arg INOUT refcursor)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT gg.peers, gg.xp FROM get_xp_all_peers() AS gg;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL pd_get_xp_everyone(res_arg := 'data');
-- FETCH ALL IN "data";
-- COMMIT;
-- END;

------------------------------------------ task 3.15
-- Определите всех сверстников, которые выполнили задания 1 и 2, но не выполнили задание 3
CREATE OR REPLACE FUNCTION get_peers_list_who_does_task(in_first_t varchar, in_second_t varchar, in_uncomplete varchar)
    RETURNS table
            (
                peers varchar
            )
AS
$$
BEGIN
    RETURN QUERY
        (SELECT DISTINCT checks.peer
         FROM checks
                  JOIN p2p ON checks.id = p2p."Check"
         WHERE p2p.state = 'Success'
           AND task = in_first_t)
        INTERSECT
        (SELECT DISTINCT checks.peer
         FROM checks
                  JOIN p2p ON checks.id = p2p."Check"
         WHERE p2p.state = 'Success'
           AND task = in_second_t)
        EXCEPT
        (SELECT DISTINCT checks.peer
         FROM checks
                  JOIN p2p ON checks.id = p2p."Check"
         WHERE p2p.state = 'Success'
           AND task = in_uncomplete);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pd_get_peers_with_cond(res_arg INOUT refcursor, in_first_t varchar,
                                                   in_second_t varchar, in_uncomplete varchar)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT *
                     FROM get_peers_list_who_does_task(in_first_t := in_first_t, in_second_t := in_second_t,
                                                       in_uncomplete := in_uncomplete);
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL pd_get_peers_with_cond(res_arg := 'data', in_first_t := 'C1', in_second_t := 'C2', in_uncomplete := 'C3');
-- FETCH ALL IN "data";
-- COMMIT;
-- END;


-------------------------------------------- task 3.16
-- Используя рекурсивное общее табличное выражение, выведите количество предыдущих задач для каждой задачи
CREATE OR REPLACE PROCEDURE pd_task_list_until(res_arg INOUT refcursor)
AS
$$
BEGIN
    OPEN res_arg FOR WITH RECURSIVE recourse_with AS (SELECT tasks.title, 0 AS count
                                                      FROM tasks
                                                      WHERE tasks.title = 'C1'

                                                      UNION ALL

                                                      SELECT tasks.title AS title, count + 1 AS count
                                                      FROM tasks
                                                               JOIN recourse_with
                                                                    ON tasks.parenttask = recourse_with.title)
                     SELECT recourse_with.title AS title, recourse_with.count AS count
                     FROM recourse_with;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL pd_task_list_until(res_arg := 'data');
-- FETCH ALL IN "data";
-- END;


----------------------------------------------  3.17
-- Найдите "счастливые" дни для проверок. День считается "удачным",
-- если в нем есть хотя бы N последовательных успешных проверок

CREATE OR REPLACE PROCEDURE pr_lucky_day_checks_3_17(in_n bigint, res INOUT refcursor)
    LANGUAGE plpgsql AS
$$
DECLARE
    count_true int     = 0;
    temp       record;
    flag_true  boolean = FALSE;
    rang       int     = 0;
BEGIN
    DROP TABLE IF EXISTS temp_table;
    CREATE TEMPORARY TABLE temp_table
    (
        days date
    );

    FOR temp IN
        SELECT dense_rank() OVER (ORDER BY checks.date) AS num, checks.id, date, x.xpamount IS NOT NULL AS result
        FROM checks
                 LEFT JOIN xp x ON checks.id = x."Check"
        ORDER BY 2
        LOOP
            IF flag_true = FALSE OR rang != temp.num
            THEN
                count_true = 0;
            END IF;

            IF temp.result = TRUE THEN
                count_true = count_true + 1;
                flag_true = TRUE;
            ELSE
                count_true = 0;
                flag_true = FALSE;
            END IF;


            IF count_true = in_n THEN INSERT INTO temp_table VALUES (temp.date); END IF;
            RAISE NOTICE 'temp = %, flag_true :%, count :%', temp, flag_true, count_true;
            rang = temp.num;
        END LOOP;

    OPEN res FOR
        SELECT DISTINCT * FROM temp_table;

END
$$;

-- BEGIN;
--     call pr_lucky_day_checks_3_17(2,'ress');
--     FETCH ALL IN "ress";
-- END;


-- task 3.18
-- Определите партнера с наибольшим количеством выполненных заданий
CREATE OR REPLACE FUNCTION get_max_count_task()
    RETURNS table
            (
                peers varchar,
                count bigint
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT DISTINCT checks.peer, count(*)
        FROM p2p
                 JOIN checks ON p2p."Check" = checks.id
                 JOIN tasks ON checks.task = tasks.title
        WHERE p2p.state = 'Success'
        GROUP BY checks.peer
        ORDER BY 2 DESC
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pd_get_max_count_tasks(res_arg INOUT refcursor)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT * FROM get_max_count_task();
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL pd_get_max_count_tasks(res_arg := 'data');
-- FETCH ALL IN "data";
-- END;

-- task 3.19
-- Найдите партнера с наибольшим количеством опыта
CREATE OR REPLACE FUNCTION get_highest_xp_peer()
    RETURNS table
            (
                peers varchar,
                xp    numeric
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT *
        FROM get_xp_all_peers()
        ORDER BY xp DESC
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pd_get_the_highest_xp_peer(res_arg INOUT refcursor)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT * FROM get_highest_xp_peer();
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL pd_get_the_highest_xp_peer(res_arg := 'data');
-- FETCH ALL "data";
-- END;

-- task 3.20
-- Найдите сверстника, который провел сегодня в кампусе больше всего времени
CREATE OR REPLACE FUNCTION get_most_motivated_peer()
    RETURNS varchar AS
$$
DECLARE
    result varchar;
BEGIN
    result =
            (SELECT last_call.peer
             FROM (SELECT gabella.peer, (gabella.sum - gg.sum)
                   FROM (SELECT peer, sum(time)
                         FROM timetracking
                         WHERE state = 2
                         GROUP BY peer) AS gabella
                            JOIN
                        (SELECT peer, sum(time)
                         FROM timetracking
                         WHERE state = 1
                         GROUP BY peer) AS gg
                        ON gg.peer = gabella.peer
                   ORDER BY 2 DESC
                   LIMIT 1) AS last_call);
    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pd_get_most_motivated_peer(res_arg INOUT refcursor)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT * FROM get_most_motivated_peer();
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL pd_get_most_motivated_peer(res_arg := 'data');
-- FETCH ALL "data";
-- END;

--task 3.21
--  Определите пиров, которые появлялись до заданного времени не менее N раз за все время
CREATE OR REPLACE FUNCTION peers_gone_until_time(in_value time, in_number integer)
    RETURNS table
            (
                peers varchar
            )
AS
$$
BEGIN
    RETURN QUERY
        (SELECT peer
         FROM timetracking
         WHERE time < in_value
         GROUP BY peer
         HAVING count(*) >= in_number);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pd_get_peers_gone_until_time(res_arg INOUT refcursor, in_value time, in_number integer)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT * FROM peers_gone_until_time(in_value := in_value, in_number := in_number);
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL pd_get_peers_gone_until_time(res_arg := 'data', in_value := '23:00:00', in_number := 1);
-- FETCH ALL "data";
-- END;

--task 3.22
-- Определите сверстников, которые покидали кампус более M раз за последние N дней
CREATE OR REPLACE FUNCTION peers_come_out_from_campus(in_day integer, in_number integer)
    RETURNS table
            (
                peers varchar
            )
AS
$$
DECLARE
    anchor date = now()::date - in_day + 1;
BEGIN
    RETURN QUERY
        SELECT peer
        FROM timetracking
        WHERE date > anchor
          AND state = '2'
        GROUP BY peer
        HAVING count(*) > in_number;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pd_lost_campus(res_arg INOUT refcursor, in_day integer, in_number integer)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT * FROM peers_come_out_from_campus(in_day := in_day, in_number := in_number);
END;
$$ LANGUAGE plpgsql;


-- BEGIN;
-- CALL pd_lost_campus(res_arg := 'data', in_day := 100, in_number := 1);
-- FETCH ALL "data";
-- END;

-- task 3.23
-- Определите, кто из сверстников пришел сегодня последним
CREATE OR REPLACE FUNCTION get_last_come_in_peer()
    RETURNS table
            (
                peers varchar
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT peer
        FROM timetracking
        WHERE state = '1'
          AND date = now()::date
        ORDER BY time DESC
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pd_get_lost_in_peer(res_arg INOUT refcursor)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT * FROM get_last_come_in_peer();
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL pd_get_lost_in_peer(res_arg := 'data');
-- FETCH ALL "data";
-- END;

-- task 3.24
-- Определите коллегу, который вчера покинул кампус более чем на N минут
CREATE OR REPLACE FUNCTION get_peers_leave_campus(in_minute integer)
    RETURNS table
            (
                peers varchar
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT gg.peer
        FROM (SELECT peer, min(time)
              FROM timetracking
              WHERE date = now()::date
                AND state = '2'
              GROUP BY peer) AS gg
                 JOIN
             (SELECT peer, max(time)
              FROM timetracking
              WHERE date = now()::date
                AND state = '1'
              GROUP BY peer) AS gabella
             ON gg.peer = gabella.peer
        WHERE (gabella.max - gg.min) > make_time(0, in_minute, 0.00);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE get_peers_leave_campus_min(res_arg INOUT refcursor, in_minute integer)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT * FROM get_peers_leave_campus(in_minute := in_minute);
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL get_peers_leave_campus_min(res_arg := 'data', in_minute := 1);
-- FETCH ALL "data";
-- END;

-- task 3.25
-- Определите для каждого месяца процент ранних записей
INSERT INTO timetracking(peer, date, time, state)
VALUES ('victoriv', '2019-04-18', '21:03:03', 1),
       ('victoriv', '2019-04-18', '21:53:03', 2),
       ('imagnifi', '2019-01-18', '03:03:03', 1),
       ('imagnifi', '2019-01-18', '11:53:03', 2),
       ('victoriv', '2019-11-18', '11:03:03', 1),
       ('victoriv', '2019-11-18', '21:33:03', 2);

CREATE OR REPLACE FUNCTION magic_array()
    RETURNS table
            (
                month integer,
                count integer
            )
AS
$$
DECLARE
    out_months integer array[0];
    out_names  integer array[0];
    early      integer array[0];
BEGIN
    FOR i IN 0..11
        LOOP
            out_names[i] = i + 1;
            out_months[i] =
                    (SELECT count(*)
                     FROM timetracking
                              JOIN peers ON timetracking.peer = peers.nickname
                     WHERE out_names[i] = date_part('month', peers.birthday)
                       AND timetracking.state = 1) AS gg;
            early[i] =
                    (SELECT count(*)
                     FROM timetracking
                              JOIN peers ON timetracking.peer = peers.nickname
                     WHERE out_names[i] = date_part('month', peers.birthday)
                       AND timetracking.state = 1
                       AND timetracking.time < '12:00:00'::time) AS gg;
            IF out_months[i] > 0 THEN
                out_months[i] = (early[i] * 100) / out_months[i];
            END IF;
        END LOOP;

    RETURN QUERY
        SELECT unnest(out_names) AS first, unnest(out_months) AS second;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE get_statistics(res_arg INOUT refcursor)
AS
$$
BEGIN
    OPEN res_arg FOR SELECT to_char(to_date(h.month::text, 'MM'), 'Month') AS mounth,
                            h.count                                        AS procent
                     FROM (SELECT gg.month, gg.count FROM magic_array() AS gg) AS h;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL get_statistics(res_arg := 'data');
-- FETCH ALL "data";
-- END;
