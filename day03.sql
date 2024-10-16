-- Изменение данных на основе языка DML.

-- DML Операторы используются для вставки, обновления и удаления данных в базе данных.
-- SELECT, INSERT, UPDATE, DELETE, MERGE, CALL, EXPLAIN PLAN

-- Выборка названий пиццы, цен на пиццу, названий пиццерий и дат посещения для Кейт и для цен в диапазоне от 800 до 1000 рублей.
SELECT m.pizza_name, m.price, pi.name AS pizzeria_name, pv.visit_date
FROM menu m
JOIN pizzeria pi ON m.pizzeria_id = pi.id
JOIN person_visits pv ON pi.id = pv.pizzeria_id
JOIN person p ON p.id = pv.person_id AND p.name = 'Kate'
WHERE m.price BETWEEN 800 AND 1000
ORDER BY 1, 2, 3;

-- id позиций меню, которые никто не заказал.
SELECT id AS menu_id
FROM menu
WHERE id NOT IN (SELECT menu_id FROM person_order)
ORDER BY menu_id;

-- Выборка пицц, их цен и пиццерий, которые никто не заказал.
SELECT m.pizza_name, m.price, pi.name AS pizzeria_name
FROM menu m
JOIN pizzeria pi on pi.id = m.pizzeria_id
WHERE m.id NOT IN (SELECT menu_id FROM person_order)
ORDER BY 1,2;

-- Выборка пиццерий, которые женщины посещали чаще, чем мужчины с сохранением дубликатов.
WITH female_orders
    AS (SELECT pi.name AS pizzeria_name
        FROM person_visits pv
        JOIN pizzeria pi ON pi.id = pv.pizzeria_id
        JOIN person p ON pv.person_id = p.id AND p.gender = 'female'),
male_orders
    AS (SELECT pi.name AS pizzeria_name
        FROM person_visits pv
        JOIN pizzeria pi ON pi.id = pv.pizzeria_id
        JOIN person p ON pv.person_id = p.id AND p.gender = 'male')
(SELECT * FROM female_orders
EXCEPT ALL
SELECT * FROM male_orders)
UNION ALL
(SELECT * FROM male_orders
EXCEPT ALL
SELECT * FROM female_orders)
ORDER BY 1;

-- Выборка объединения пиццерий, в которых заказывают только женщины или только мужчины.
WITH female_orders
    AS (SELECT pi.name AS pizzeria_name
        FROM person_order po
        JOIN menu m ON m.id = po.menu_id
        JOIN pizzeria pi ON pi.id = m.pizzeria_id
        JOIN person p ON po.person_id = p.id AND p.gender = 'female'),
male_orders
    AS (SELECT pi.name AS pizzeria_name
        FROM person_order po
        JOIN menu m ON m.id = po.menu_id
        JOIN pizzeria pi ON pi.id = m.pizzeria_id
        JOIN person p ON po.person_id = p.id AND p.gender = 'male')
(SELECT * FROM female_orders
EXCEPT
SELECT * FROM male_orders)
UNION
(SELECT * FROM male_orders
EXCEPT
SELECT * FROM female_orders)
ORDER BY 1;

-- Выборка пиццерий, которые посетил Андрей, но не сделал ни одного заказа.
(SELECT pi.name AS pizzeria_name
FROM pizzeria pi
JOIN person_visits pv ON pi.id = pv.pizzeria_id
JOIN person p ON pv.person_id = p.id AND p.name = 'Andrey')
INTERSECT
(SELECT pi.name
FROM pizzeria pi
JOIN menu m ON pi.id = m.pizzeria_id
WHERE m.id NOT IN (SELECT menu_id FROM person_order po JOIN person p ON po.person_id = p.id AND p.name = 'Andrey'))
ORDER BY 1;

-- Выборка пиццы с одинаковой ценой, но из разных пиццерий.
SELECT m_1.pizza_name, pi_1.name AS pizzeria_name_1, pi_2.name AS pizzeria_name_2, m_1.price
FROM menu m_1, menu m_2
JOIN pizzeria pi_1 ON m_2.pizzeria_id = pi_1.id
JOIN pizzeria pi_2 ON m_2.pizzeria_id = pi_2.id
WHERE m_1.id != m_2.id AND m_1.price = m_2.price AND m_1.pizzeria_id > m_2.pizzeria_id AND m_1.pizza_name = m_2.pizza_name
ORDER BY 1;

-- Добавление новой пиццы в меню.
INSERT INTO menu (id, pizzeria_id, pizza_name, price) VALUES (19, 2, 'greek pizza', 800);

-- Добавление новой пиццы в менб с условиями.
INSERT INTO menu (id, pizzeria_id, pizza_name, price)
VALUES ((SELECT MAX(id) + 1 FROM menu), (SELECT id FROM pizzeria WHERE name = 'Dominos'), 'sicilian pizza', 900);

-- Добавление новых посещений.
INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) + 1 FROM person_visits),
        (SELECT id FROM person WHERE name = 'Denis'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'),
        '2022-02-24');

INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) + 1 FROM person_visits),
        (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'),
        '2022-02-24');

-- Добавление новых заказов.
INSERT INTO person_order (id, person_id, menu_id, order_date)
VALUES ((SELECT MAX(id) + 1 FROM person_order),
        (SELECT id FROM person WHERE name = 'Denis'),
        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza'),
        '2022-02-24');

INSERT INTO person_order (id, person_id, menu_id, order_date)
VALUES ((SELECT MAX(id) + 1 FROM person_order),
        (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza'),
        '2022-02-24');

-- Обновление цены пиццы со скидкой.
UPDATE menu SET price = price * 0.9
WHERE pizza_name = 'greek pizza';

-- Добавление значений с помощью generate_series.
INSERT INTO person_order (id, person_id, menu_id, order_date)
SELECT generate_series((SELECT MAX(id) + 1 FROM person_order), (SELECT MAX(id) FROM person_order) + (SELECT COUNT(id) FROM person)),
       generate_series(1, (SELECT MAX(id) FROM person)),
       (SELECT id FROM menu WHERE pizza_name = 'greek pizza'),
       '2022-02-25';

-- Удаление значений из таблиц.
DELETE FROM person_order WHERE order_date = '2022-02-25';
DELETE FROM menu WHERE pizza_name = 'greek pizza';