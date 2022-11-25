-- DROP DATABASE IF EXISTS "school_s21";
-- CREATE DATABASE "school_s21" ENCODING 'UTF8';


CREATE TABLE IF NOT EXISTS peers
(
    nickname varchar PRIMARY KEY,
    birthday date
);


CREATE TABLE IF NOT EXISTS tasks
(
    title      varchar PRIMARY KEY,
    parenttask varchar DEFAULT 0,
    maxxp      bigint  DEFAULT 0 CHECK ( maxxp >= 0 ),
    CONSTRAINT fk_tasks_parenttask FOREIGN KEY (parenttask) REFERENCES tasks (title)
);


CREATE TABLE IF NOT EXISTS checks
(
    id   serial PRIMARY KEY NOT NULL,
    peer varchar            NOT NULL,
    task varchar            NOT NULL,
    date date               NOT NULL,
    CONSTRAINT fk_checks_peers_nickname FOREIGN KEY (peer) REFERENCES peers (nickname),
    CONSTRAINT fk_checks_tasks_title FOREIGN KEY (task) REFERENCES tasks (title)
);

DROP TYPE IF EXISTS "check_status" CASCADE;
CREATE TYPE "check_status" AS enum (
    'Start',
    'Success',
    'Failure'
    );

CREATE TABLE IF NOT EXISTS p2p
(
    id           serial PRIMARY KEY NOT NULL,
    "Check"      bigint             NOT NULL,
    checkingpeer varchar            NOT NULL,
    state        check_status,
    time         timestamp          NOT NULL,
    CONSTRAINT fk_p2p_checks_id FOREIGN KEY ("Check") REFERENCES checks (id),
    CONSTRAINT fk_p2p_peers_nickname FOREIGN KEY (checkingpeer) REFERENCES peers (nickname)
);

CREATE TABLE IF NOT EXISTS verter
(
    id      serial PRIMARY KEY NOT NULL,
    "Check" bigint             NOT NULL,
    state   check_status,
    time    timestamp          NOT NULL,
    CONSTRAINT fk_verter_checks_id FOREIGN KEY ("Check") REFERENCES checks (id)
);



CREATE TABLE IF NOT EXISTS transferredpoints
(
    id           serial PRIMARY KEY NOT NULL,
    checkingpeer varchar            NOT NULL,
    checkedpeer  varchar            NOT NULL,
    pointsamount bigint,
    CONSTRAINT fk_transferredpoints_peers_nickname FOREIGN KEY (checkingpeer) REFERENCES peers (nickname),
    CONSTRAINT fk_transferredpoints1_peers_nickname FOREIGN KEY (checkedpeer) REFERENCES peers (nickname)
);

CREATE TABLE IF NOT EXISTS friends
(
    id    serial PRIMARY KEY NOT NULL,
    peer1 varchar CHECK ( peer1 != friends.peer2 ),
    peer2 varchar CHECK ( peer2 != friends.peer1 ),
    CONSTRAINT fk_friends_peers_nickname FOREIGN KEY (peer1) REFERENCES peers (nickname),
    CONSTRAINT fk_friends1_peers_nickname FOREIGN KEY (peer2) REFERENCES peers (nickname),
    CONSTRAINT un_friends UNIQUE (peer1, peer2)
);

CREATE TABLE IF NOT EXISTS recommendations
(
    id              serial PRIMARY KEY NOT NULL,
    peer            varchar            NOT NULL,
    recommendedpeer varchar            NOT NULL,
    CONSTRAINT fk_recommendations_peers_nickname FOREIGN KEY (peer) REFERENCES peers (nickname),
    CONSTRAINT fk_recommendations1_peers_nickname FOREIGN KEY (recommendedpeer) REFERENCES peers (nickname),
    CONSTRAINT un_recommendations UNIQUE (peer, recommendedpeer)
);

CREATE TABLE IF NOT EXISTS xp
(
    id       serial PRIMARY KEY NOT NULL,
    "Check"  bigint             NOT NULL,
    xpamount bigint CHECK ( xpamount >= 0 ),
    CONSTRAINT fk_xp_checks_id FOREIGN KEY ("Check") REFERENCES checks (id)
);

CREATE TABLE IF NOT EXISTS timetracking
(
    id    serial PRIMARY KEY NOT NULL,
    peer  varchar            NOT NULL,
    date  date               NOT NULL,
    time  time               NOT NULL,
    state integer CHECK ( state IN (1, 2) ),
    CONSTRAINT fk_timetracking_peers_nickname FOREIGN KEY (peer) REFERENCES peers (nickname)
);

CREATE TABLE IF NOT EXISTS vertertasks
(
    task varchar PRIMARY KEY,
    CONSTRAINT fk_vertertask_tasks FOREIGN KEY (task) REFERENCES tasks (title)
);

------------------  fill tabels

