-- created by victoriv
CREATE OR REPLACE FUNCTION fnc_get_last_p2p(in_name varchar)
    RETURNS bigint AS
$$
BEGIN
    RETURN (SELECT max("Check")
            FROM p2p
            WHERE time =
                  (SELECT max(p2p.time) FROM p2p WHERE p2p.state = 'Start' AND p2p.checkingpeer = in_name)
              AND p2p.state = 'Start');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnc_checking_peer_tasks(in_peer varchar, in_task varchar)
    RETURNS boolean AS
$$
BEGIN
    IF in_task IN ('C1', 'CPP1') THEN
        RETURN TRUE;
    END IF;

    IF
        ((SELECT title
          FROM p2p
                   JOIN checks ON p2p."Check" = checks.id
                   JOIN tasks ON checks.task = tasks.title
                   JOIN xp x ON checks.id = x."Check"
          WHERE p2p.state = 'Success'
            AND checks.peer = in_peer)
         INTERSECT
         (SELECT parenttask FROM tasks WHERE title = in_task)
         LIMIT 1) IS NOT NULL
    THEN
        RETURN TRUE;

    ELSE
        RETURN FALSE;
    END IF;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE pr_add_p2p_check(in_checked_peer varchar,
                                             in_checking_peer varchar,
                                             in_task varchar,
                                             in_state check_status,
                                             in_time timestamp DEFAULT current_timestamp)
AS
$$
DECLARE
    real_time      timestamp := in_time;
    actual_id      integer   := fnc_get_last_p2p(in_name := in_checking_peer);
    is_task_passed int       = 0;
    is_task_start  int       = 0;
BEGIN

    SELECT "Check"
    INTO is_task_start
    FROM p2p p
             JOIN checks c ON c.id = p."Check" AND in_task = c.task
    WHERE checkingpeer = in_checking_peer
    ORDER BY p.id DESC
    LIMIT 1;

    SELECT count(*)
    INTO is_task_passed
    FROM checks
             JOIN xp ON xp."Check" = is_task_start;

    IF in_state = 'Success' AND is_task_passed = 0 AND is_task_start <> 0
    THEN
        INSERT INTO p2p("Check", checkingpeer, state, time)
        VALUES (actual_id, in_checking_peer, 'Success', real_time);
    END IF;

    IF in_state = 'Failure' AND is_task_passed = 0 AND is_task_start <> 0 THEN
        INSERT INTO p2p("Check", checkingpeer, state, time)
        VALUES (actual_id, in_checking_peer, 'Failure', real_time);
    END IF;

    IF in_state = 'Start' AND fnc_checking_peer_tasks(in_peer := in_checked_peer, in_task := in_task) THEN

        INSERT INTO checks(peer, task, date)
        VALUES (in_checked_peer, in_task, real_time);

        INSERT INTO p2p("Check", checkingpeer, state, time)
        VALUES ((SELECT max(id) FROM checks), in_checking_peer, 'Start', real_time);

    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnc_is_task_from_checks(in_peer varchar, in_task_name varchar) RETURNS boolean
    LANGUAGE plpgsql AS
$$
DECLARE
    res boolean DEFAULT FALSE;
BEGIN
    IF ((SELECT count(*)
         FROM checks
                  JOIN p2p p ON checks.id = p."Check"
                  JOIN xp x ON checks.id = x."Check"
         WHERE in_task_name = task
           AND in_peer = checks.peer) = 0)
    THEN
        res = TRUE;
    END IF;
    RETURN res;
END
$$;


CREATE OR REPLACE PROCEDURE pr_add_verter_check(
    in_nickname varchar,
    in_task varchar,
    in_status check_status,
    in_time timestamp)
    LANGUAGE plpgsql AS
$$
DECLARE
    from_table_checks checks%rowtype;
    p2p_check         p2p%rowtype;
    verter_check      bigint DEFAULT 0;
BEGIN

    SELECT *
    INTO from_table_checks
    FROM (SELECT *
          FROM checks
          WHERE task = in_task
            AND peer = in_nickname
          EXCEPT
          SELECT checks.id, checks.peer, checks.task, checks.date
          FROM checks
                   JOIN xp x ON checks.id = x."Check") f;

    IF in_status = 'Start' THEN
        SELECT *
        INTO p2p_check
        FROM p2p
                 JOIN checks c ON c.id = p2p."Check" AND in_nickname = c.peer AND in_task = c.task
        WHERE state = 'Success';

        SELECT verter.id
        INTO verter_check
        FROM verter
                 JOIN checks c2 ON c2.id = verter."Check" AND c2.peer = in_nickname
        WHERE fnc_is_task_from_checks(in_nickname, in_task)
          AND verter.state = 'Start'
          AND verter.id = (SELECT max(id) FROM verter);

        IF (SELECT count(*) from_table_checks) = 1
               AND (SELECT count(*) p2p_check) = 1
               AND verter_check IS NULL OR verter_check = 0
        THEN

            INSERT INTO verter("Check", state, time)
            VALUES (from_table_checks.id, in_status, in_time);
        END IF;
    ELSE
        IF in_status = 'Success' OR in_status = 'Failure' THEN
            SELECT "Check"
            INTO verter_check
            FROM verter
            WHERE fnc_is_task_from_checks(in_nickname, in_task)
              AND verter.state = 'Start'
              AND (SELECT state FROM verter WHERE id = currval('verter_id_seq')) != 'Success';
            IF (verter_check IS NOT NULL) THEN
                INSERT INTO verter("Check", state, time) VALUES (from_table_checks.id, in_status, in_time);
            END IF;
        END IF;
    END IF;
END ;
$$;


CREATE OR REPLACE FUNCTION fnc_tr_p2p_success() RETURNS trigger
    LANGUAGE plpgsql AS
$tr_p2p_success$
DECLARE
    peer_   varchar;
    task_   varchar;
    status_ check_status;
    maxxp_  bigint;
BEGIN
    SELECT t.maxxp
    INTO maxxp_
    FROM p2p
             JOIN checks c ON new."Check" = c.id
             JOIN tasks t ON t.title = c.task;
    IF (SELECT task FROM checks WHERE id = new."Check") IN (SELECT * FROM vertertasks) THEN
        SELECT peer INTO peer_ FROM checks WHERE new."Check" = checks.id;
        SELECT task INTO task_ FROM checks WHERE new."Check" = checks.id;
        CALL pr_add_verter_check(
                peer_,
                task_,
                'Start'::check_status,
                now()::timestamp);
        PERFORM pg_sleep(1.5);
        IF (SELECT random()) > 0.5 THEN status_ = 'Success'; ELSE status_ = 'Failure'; END IF;
        CALL pr_add_verter_check(
                peer_,
                task_,
                status_::check_status,
                now()::timestamp);
        IF (status_ = 'Success') THEN
            INSERT INTO xp("Check", xpamount)
            VALUES (new."Check", (random() * (maxxp_ - (maxxp_ * 0.8))) + (maxxp_ * 0.8));
        END IF;
    ELSE
        INSERT INTO xp("Check", xpamount) VALUES (new."Check", (random() * (maxxp_ - (maxxp_ * 0.8))) + (maxxp_ * 0.8));
    END IF;

    RETURN NULL;
END
$tr_p2p_success$;


CREATE OR REPLACE TRIGGER tr_p2p_success
    AFTER INSERT
    ON p2p
    FOR EACH ROW
    WHEN ( new.state = 'Success' )
EXECUTE FUNCTION fnc_tr_p2p_success();


----- 2.3

CREATE OR REPLACE FUNCTION fnc_tr_p2p_start() RETURNS trigger
    LANGUAGE plpgsql AS
$tr_p2p_start$
DECLARE
    checkedpeer_ varchar;
    pair_id_     bigint DEFAULT 0;
BEGIN
    SELECT INTO checkedpeer_ c.peer
    FROM p2p
             JOIN checks c ON c.id = new."Check";

    SELECT id
    INTO pair_id_
    FROM transferredpoints
    WHERE (checkingpeer = new.checkingpeer AND checkedpeer = checkedpeer_)
       OR (checkingpeer = checkedpeer_ AND checkedpeer = new.checkingpeer);

    IF (pair_id_ != 0) THEN
        IF (SELECT checkingpeer FROM transferredpoints WHERE id = pair_id_) = new.checkingpeer AND
           (SELECT checkedpeer FROM transferredpoints WHERE id = pair_id_) = checkedpeer_ THEN
            UPDATE transferredpoints
            SET pointsamount = pointsamount + 1
            WHERE id = pair_id_;
        ELSE
            IF (SELECT checkingpeer FROM transferredpoints WHERE id = pair_id_) = checkedpeer_ AND
               (SELECT checkedpeer FROM transferredpoints WHERE id = pair_id_) = new.checkingpeer THEN
                UPDATE transferredpoints
                SET pointsamount = pointsamount - 1
                WHERE id = pair_id_;
            END IF;
        END IF;
    ELSE
        INSERT INTO transferredpoints(checkingpeer, checkedpeer, pointsamount)
        VALUES (new.checkingpeer, checkedpeer_, 1);
    END IF;
    RETURN NULL;
END;
$tr_p2p_start$;

CREATE OR REPLACE TRIGGER tr_p2p_start
    AFTER INSERT
    ON p2p
    FOR EACH ROW
    WHEN ( new.state = 'Start' )
EXECUTE FUNCTION fnc_tr_p2p_start();

----- 2.4

CREATE OR REPLACE FUNCTION fnc_tr_xp_insert()
    RETURNS trigger
    LANGUAGE plpgsql AS
$tr_xp_insert$
BEGIN
    IF fnc_control_insert_xp(new."Check", new.xpamount) = TRUE THEN
        RETURN new;
    ELSE
        RETURN NULL;
    END IF;
END;
$tr_xp_insert$;

CREATE OR REPLACE FUNCTION fnc_control_insert_xp(check_ bigint, curxp_ bigint) RETURNS boolean
    LANGUAGE plpgsql AS
$control$
DECLARE
    result boolean;
BEGIN
    SELECT temp.record
    INTO result
    FROM (SELECT CASE
                     WHEN (curxp_ <= maxxp)
                         THEN TRUE
                     ELSE FALSE END AS record
          FROM checks
                   JOIN p2p ON checks.id = p2p."Check"
                   JOIN tasks ON tasks.title = checks.task
          WHERE checks.id = check_) AS temp;
    RETURN result;
END;
$control$;

CREATE OR REPLACE TRIGGER tr_xp_insert
    BEFORE INSERT
    ON xp
    FOR EACH ROW
EXECUTE FUNCTION fnc_tr_xp_insert();

