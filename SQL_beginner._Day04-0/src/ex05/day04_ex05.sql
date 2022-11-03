drop view if exists v_price_with_discount;
CREATE VIEW v_price_with_discount AS
(
SELECT p.name, pizza_name, price, round(price - price*0.1) AS discount_price
FROM person_order po
JOIN person p ON p.id = po.person_id
JOIN menu m ON m.id = po.menu_id
ORDER BY 1, 2
)











