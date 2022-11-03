-- SELECT * FROM pg_indexes WHERE tablename = 'person_order';
-- drop index idx_person_order_person_id;
-- drop index idx_person_order_menu_id;
-- drop index idx_person_order_multi;
-- drop index idx_person_order_order_date;


CREATE UNIQUE INDEX idx_person_order_order_date
ON person_order (person_id, menu_id)
where order_date = '2022-01-01';

EXPLAIN ANALYZE
SELECT person_id, menu_id FROM person_order where order_date = '2022-01-01';
