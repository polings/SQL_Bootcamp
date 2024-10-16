-- Изучение операторов множеств UNION[ALL], EXCEPT[ALL], INTERSECT[ALL], а также простых JOIN'ов 

-- ex00
SELECT id AS object_id, pizza_name AS object_name FROM menu
UNION
SELECT id, name FROM person
ORDER BY object_id, object_name;

-- ex01
(SELECT name FROM person
ORDER BY name)
UNION ALL
(SELECT pizza_name AS object_name FROM menu
ORDER BY object_name);

-- ex02
SELECT pizza_name FROM menu
INTERSECT
SELECT pizza_name FROM menu
ORDER BY pizza_name DESC;

-- ex03
SELECT order_date AS action_date, person_id FROM person_order
INTERSECT
SELECT visit_date, person_id FROM person_visits
ORDER BY action_date, person_id DESC;

-- ex04
SELECT person_id FROM person_order
WHERE order_date = '2022-01-07'
EXCEPT ALL
SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-07';

-- ex05
SELECT * FROM person pe
CROSS JOIN pizzeria pi
ORDER BY pe.id, pi.id;

-- ex06
SELECT distinct po.order_date AS action_date, p.name AS person_name
FROM person_order po
INNER JOIN person p ON po.person_id = p.id
ORDER BY action_date, person_name DESC;

-- ex07
SELECT po.order_date, FORMAT('%s (age:%s)', p.name, p.age) person_information
FROM person_order po
JOIN person p ON p.id = po.person_id
ORDER BY po.order_date, person_information;

-- ex08
SELECT order_date, FORMAT('%s (age:%s)', p.name, p.age) person_information
FROM person_order
NATURAL JOIN person p (person_id)
ORDER BY order_date, person_information;

-- ex09
SELECT name
FROM pizzeria
WHERE id NOT IN (SELECT pizzeria_id FROM person_visits);

SELECT name
FROM pizzeria pi
WHERE NOT EXISTS (SELECT * FROM person_visits WHERE pizzeria_id = pi.id);

-- ex10
SELECT pe.name as person_name, m.pizza_name, pi.name AS pizzeria_name
FROM person_order
JOIN person pe ON person_order.person_id = pe.id
JOIN menu m ON person_order.menu_id = m.id
JOIN pizzeria pi ON m.pizzeria_id = pi.id
ORDER BY person_name, pizza_name, pizzeria_name;