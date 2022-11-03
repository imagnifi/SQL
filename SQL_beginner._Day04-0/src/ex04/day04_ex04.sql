drop view if exists v_symmetric_union;
CREATE VIEW v_symmetric_union AS
(
WITH
R AS (SELECT person_id FROM person_visits WHERE visit_date = '2022-01-02'),
S AS (SELECT person_id FROM person_visits WHERE visit_date = '2022-01-06')
(SELECT * FROM S EXCEPT SELECT * FROM R)
UNION
(SELECT * FROM R EXCEPT SELECT * FROM S)
ORDER BY 1
)





