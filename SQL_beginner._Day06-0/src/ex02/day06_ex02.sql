SELECT DISTINCT person.name, menu.pizza_name, menu.price,
       menu.price - (menu.price * person_discounts.discount / 100) AS discount_price,
       pizzeria.name AS pizzeria_name
FROM person_order JOIN menu ON person_order.menu_id = menu.id
    JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
    JOIN person_discounts ON person_order.person_id = person_discounts.person_id
        AND pizzeria.id = person_discounts.pizzeria_id
    JOIN person ON person_order.person_id = person.id
ORDER BY 1, 2