set enable_seqscan = OFF;
create unique index idx_person_discounts_unique
on person_discounts(person_id, pizzeria_id);


EXPLAIN ANALYZE
SELECT person_id, pizzeria_id FROM person_discounts;
