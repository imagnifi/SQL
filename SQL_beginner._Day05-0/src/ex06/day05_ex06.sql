-- SELECT * FROM pg_indexes WHERE tablename = 'menu';
-- drop index idx_1;
-- drop index idx_menu_pizzeria_id;
-- drop index idx_menu_unique;


create index idx_1 
ON pizzeria(rating);

EXPLAIN ANALYZE
SELECT m.pizza_name AS pizza_name,
    max(rating) OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM  menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1,2;


