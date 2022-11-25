INSERT INTO peers(nickname, birthday)
VALUES ('imagnifi', '1979-01-26'),
       ('pfidelia', '2003-11-06'),
       ('victoriv', '1994-12-04'),
       ('lcoon', '2003-03-02'),
       ('vluann', '2009-11-10'),
       ('hspeaker', '2009-11-11');

INSERT INTO friends(peer1, peer2)
VALUES ('pfidelia', 'lcoon'),
       ('victoriv', 'vluann'),
       ('pfidelia', 'imagnifi'),
       ('lcoon', 'hspeaker'),
       ('imagnifi', 'victoriv');

INSERT INTO recommendations(peer, recommendedpeer)
VALUES ('victoriv', 'imagnifi'),
       ('pfidelia', 'lcoon'),
       ('victoriv', 'vluann'),
       ('lcoon', 'victoriv'),
       ('imagnifi', 'pfidelia'),
       ('vluann', 'imagnifi'),
       ('hspeaker', 'pfidelia');

INSERT INTO timetracking(peer, date, time, state)
VALUES ('imagnifi', '2022-03-03', '04:05:06', 1),
       ('victoriv', '2022-06-07', '20:02:03', 1),
       ('pfidelia', '2022-08-09', '21:03:03', 2),
       ('vluann', '2022-09-09', '22:06:30', 1),
       ('hspeaker', '2010-03-02', '13:03:04', 1),
       ('hspeaker', '2022-06-07', '18:35:00', 2),
       ('lcoon', '2022-04-05', '05:06:08', 2),
       ('vluann', '2022-09-09', '23:06:30', 2),
       ('vluann', '2022-09-09', '22:06:30', 1),
       ('vluann', '2022-09-09', '23:06:30', 2),
       ('lcoon', now()::date, now()::time, 1),
       ('lcoon', '2022-06-07', '06:06:30', 1),
       ('lcoon', '2022-06-07', '07:16:30', 2),
       ('lcoon', '2022-06-07', '07:56:30', 1),
       ('lcoon', '2022-06-07', '22:06:30', 2);

INSERT INTO tasks(title, parenttask, maxxp)
VALUES ('CPP1', 'C5', 250),
       ('CPP2', 'CPP1', 300),
       ('CPP3', 'CPP2', 600),
       ('CPP4', 'CPP3', 800),
       ('CPP5', 'CPP4', 1000),
       ('C1', NULL, 250),
       ('C2', 'C1', 300),
       ('C3', 'C2', 600),
       ('C4', 'C3', 800),
       ('C5', 'C4', 1000);

INSERT INTO vertertasks(task)
VALUES ('C1'),
       ('C2'),
       ('C3'),
       ('C4');


-- begin блок заполнения by pfidelia, можно выполнить разом
CALL pr_add_p2p_check('vluann', 'imagnifi', 'C1', 'Start', '2022-11-10 12:01:52'::timestamp);
CALL pr_add_p2p_check('vluann', 'imagnifi', 'C1', 'Success', '2022-11-10 12:01:50'::timestamp);
CALL pr_add_p2p_check('imagnifi', 'vluann', 'C1', 'Start', '2022-11-10  12:02:52'::timestamp);
CALL pr_add_p2p_check('imagnifi', 'vluann', 'C1', 'Success', '2022-11-10  12:12:52'::timestamp);
CALL pr_add_p2p_check('vluann', 'imagnifi', 'C2', 'Start', '2022-11-10  12:12:52'::timestamp);
CALL pr_add_p2p_check('vluann', 'imagnifi', 'C2', 'Success', '2022-11-10  12:22:52'::timestamp);
CALL pr_add_p2p_check('imagnifi', 'pfidelia', 'C2', 'Start', '2022-11-10  12:12:52'::timestamp);
CALL pr_add_p2p_check('imagnifi', 'pfidelia', 'C2', 'Success', '2022-11-10  12:22:52'::timestamp);
CALL pr_add_p2p_check('vluann', 'victoriv', 'C3', 'Start', '2022-11-10  12:22:52'::timestamp);
CALL pr_add_p2p_check('vluann', 'victoriv', 'C3', 'Success', '2022-11-10  12:32:52'::timestamp);
CALL pr_add_p2p_check('pfidelia', 'victoriv', 'C2', 'Start', '2022-11-10  12:32:52'::timestamp);
CALL pr_add_p2p_check('pfidelia', 'victoriv', 'C2', 'Success', '2022-11-10  12:42:52'::timestamp);

CALL pr_add_p2p_check('hspeaker', 'lcoon', 'C1', 'Start', '2022-11-11 11:50:52'::timestamp);
CALL pr_add_p2p_check('hspeaker', 'lcoon', 'C1', 'Success', '2022-11-11 11:59:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'vluann', 'CPP1', 'Start', '2022-11-11 12:00:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'vluann', 'CPP1', 'Success', '2022-11-11 12:10:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'lcoon', 'CPP2', 'Start', '2022-11-11 12:10:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'lcoon', 'CPP2', 'Success', '2022-11-11 12:20:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'imagnifi', 'CPP3', 'Start', '2022-11-11 12:20:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'imagnifi', 'CPP3', 'Success', '2022-11-11 12:30:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'hspeaker', 'CPP4', 'Start', '2022-11-11 12:30:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'hspeaker', 'CPP4', 'Success', '2022-11-11 12:40:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'pfidelia', 'CPP5', 'Start', '2022-11-11 12:40:52'::timestamp);
CALL pr_add_p2p_check('victoriv', 'pfidelia', 'CPP5', 'Success', '2022-11-11 12:50:52'::timestamp);
CALL pr_add_p2p_check('pfidelia', 'vluann', 'CPP1', 'Start', '2022-11-11 14:00:52'::timestamp);
CALL pr_add_p2p_check('pfidelia', 'vluann', 'CPP1', 'Success', '2022-11-11 14:10:52'::timestamp);
-- end блок заполнения by pfidelia, можно выполнить разом

-- begin блок параллельная проверка, выполнять по одной (!)
CALL pr_add_p2p_check('hspeaker', 'victoriv', 'CPP1', 'Start', now()::timestamp);
CALL pr_add_p2p_check('pfidelia', 'lcoon', 'CPP2', 'Start', now()::timestamp);
CALL pr_add_p2p_check('hspeaker', 'victoriv', 'CPP1', 'Success', now()::timestamp);
CALL pr_add_p2p_check('pfidelia', 'lcoon', 'CPP2', 'Success', now()::timestamp);
-- end блок параллельная проверка, выполнять по одной (!)


----------------------- 2022-11-10

CALL pr_add_p2p_check('imagnifi',
                      'pfidelia',
                      'CPP1',
                      'Start',
                      '2022-11-10'::timestamp);

CALL pr_add_p2p_check('imagnifi',
                      'pfidelia',
                      'CPP1',
                      'Success',
                      '2022-11-10'::timestamp);

CALL pr_add_p2p_check('victoriv',
                      'pfidelia',
                      'CPP1',
                      'Start',
                      '2022-11-10'::timestamp);

CALL pr_add_p2p_check('victoriv',
                      'pfidelia',
                      'CPP1',
                      'Success',
                      '2022-11-10'::timestamp);


CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C1',
                      'Start',
                      '2022-11-10'::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C1',
                      'Success',
                      '2022-11-10'::timestamp);

CALL pr_add_p2p_check('vluann',
                      'imagnifi',
                      'C2',
                      'Start',
                      '2022-11-10'::timestamp);

CALL pr_add_p2p_check('vluann',
                      'imagnifi',
                      'C2',
                      'Success',
                      '2022-11-10'::timestamp);

------------------------------ 2022-11-11

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C4',
                      'Start',
                      '2022-11-11'::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C4',
                      'Success',
                      '2022-11-11'::timestamp);

CALL pr_add_p2p_check('vluann',
                      'imagnifi',
                      'C2',
                      'Start',
                      '2022-11-11'::timestamp);

CALL pr_add_p2p_check('vluann',
                      'imagnifi',
                      'C2',
                      'Success',
                      '2022-11-11'::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C1',
                      'Start',
                      '2022-11-11'::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C1',
                      'Success',
                      '2022-11-11'::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C4',
                      'Start',
                      '2022-11-11'::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C4',
                      'Success',
                      '2022-11-11'::timestamp);

-----------------------  2022-11-12


CALL pr_add_p2p_check('victoriv',
                      'lcoon',
                      'C3',
                      'Start',
                      '2022-11-12'::timestamp);

CALL pr_add_p2p_check('victoriv',
                      'lcoon',
                      'C3',
                      'Success',
                      '2022-11-12'::timestamp);

CALL pr_add_p2p_check('lcoon',
                      'victoriv',
                      'C2',
                      'Start',
                      '2022-11-12'::timestamp);

CALL pr_add_p2p_check('lcoon',
                      'victoriv',
                      'C2',
                      'Success',
                      '2022-11-12'::timestamp);


---------------------- curent date


CALL pr_add_p2p_check('imagnifi',
                      'pfidelia',
                      'CPP1',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('imagnifi',
                      'pfidelia',
                      'CPP1',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'imagnifi',
                      'CPP1',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'imagnifi',
                      'CPP1',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('victoriv',
                      'pfidelia',
                      'CPP1',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('victoriv',
                      'pfidelia',
                      'CPP1',
                      'Success',
                      now()::timestamp);


CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C1',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C1',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('vluann',
                      'imagnifi',
                      'C1',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('vluann',
                      'imagnifi',
                      'C1',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C1',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C1',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('vluann',
                      'imagnifi',
                      'C2',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('vluann',
                      'imagnifi',
                      'C2',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C1',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C1',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C2',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C2',
                      'Success',
                      now()::timestamp);


CALL pr_add_p2p_check('victoriv',
                      'lcoon',
                      'C3',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('victoriv',
                      'lcoon',
                      'C3',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('lcoon',
                      'victoriv',
                      'C2',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('lcoon',
                      'victoriv',
                      'C2',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C2',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C2',
                      'Failure',
                      now()::timestamp);

CALL pr_add_p2p_check('imagnifi',
                      'victoriv',
                      'CPP2',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('imagnifi',
                      'victoriv',
                      'CPP2',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('imagnifi',
                      'victoriv',
                      'CPP4',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('imagnifi',
                      'victoriv',
                      'CPP4',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('imagnifi',
                      'pfidelia',
                      'CPP4',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('imagnifi',
                      'pfidelia',
                      'CPP4',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C1',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C1',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C3',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C3',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C2',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C2',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C3',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C2',
                      'Start',
                      now()::timestamp);

CALL pr_add_p2p_check('hspeaker',
                      'victoriv',
                      'C3',
                      'Success',
                      now()::timestamp);

CALL pr_add_p2p_check('pfidelia',
                      'lcoon',
                      'C2',
                      'Success',
                      now()::timestamp);


