-- delete from person_visits where id = 22;

INSERT INTO person_visits VALUES 
(
(select max(id)+1 from person_visits),
(select id from person where name = 'Dmitriy'),
(select  pizzeria_id from menu where price < 800 and pizzeria_id != 4 limit (1)),
'2022-01-08' 
);

refresh materialized view mv_dmitriy_visits_and_eats











