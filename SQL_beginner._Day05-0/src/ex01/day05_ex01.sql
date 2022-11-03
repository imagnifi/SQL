
EXPLAIN ANALYZE
select pizza_name, name FROM menu m
join pizzeria p ON m.pizzeria_id = p.id