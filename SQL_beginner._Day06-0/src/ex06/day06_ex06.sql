-------------------------- drop sequence
-- alter table person_discounts alter column id drop DEFAULT;
-- drop SEQUENCE seq_person_discounts;

create SEQUENCE seq_person_discounts START 1;

alter table person_discounts
alter column id set DEFAULT nextval ('seq_person_discounts');

SELECT setval('seq_person_discounts',
    (SELECT count(id) FROM person_discounts));


---------------------------- check insert
-- INSERT INTO person_discounts(person_id, pizzeria_id) VALUES (1, 3);
-- DELETE from person_discounts where id = 16;