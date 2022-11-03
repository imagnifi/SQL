drop materialized view if exists mv_dmitriy_visits_and_eats;
CREATE MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS 
(
WITH date_visit AS 
      (SELECT pizzeria_id, person_id
       FROM   person_visits
       WHERE  visit_date = '2022-01-08'),
     Dmitriy_pizzeria_id AS
      (SELECT pizzeria_id
       FROM   date_visit
       WHERE  person_id = (SELECT id FROM person WHERE name = 'Dmitriy'))

SELECT p.name AS pizzeria_name
FROM menu
JOIN Dmitriy_pizzeria_id dp ON dp.pizzeria_id = menu.pizzeria_id AND price < 800
JOIN pizzeria p ON dp.pizzeria_id = p.id
)











