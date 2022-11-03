
alter TABLE person_discounts
add constraint ch_nn_person_id check( person_id is NOT NULL);

alter TABLE person_discounts
add constraint ch_nn_pizzeria_id check( pizzeria_id is NOT NULL);

alter TABLE person_discounts
add constraint ch_nn_discount check( discount is NOT NULL);

alter table person_discounts
alter column discount set DEFAULT 0;

alter TABLE person_discounts
add constraint ch_range_discount check( discount between 0 and 100);

-- insert into person_discounts values (16, 2, 3, 130);
-- delete from person_discounts where id = 16;