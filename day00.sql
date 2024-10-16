-- Изучение синтаксиса SELECT.

-- ex00
SELECT name, age FROM person
WHERE address = 'Kazan';

-- ex01
SELECT name, age FROM person
WHERE address = 'Kazan' AND gender = 'female'
ORDER BY name;

-- ex02
SELECT name, rating FROM pizzeria
WHERE rating >= 3.5 AND rating <=5
ORDER BY rating;

SELECT name, rating FROM pizzeria
WHERE rating BETWEEN 3.5 AND 5
ORDER BY rating;

-- ex03
SELECT DISTINCT person_id FROM person_visits
WHERE visit_date BETWEEN '2022-01-06' AND '2022-01-09' OR pizzeria_id = 2
ORDER BY person_id DESC;

-- ex04
SELECT FORMAT('%s (age:%s,gender:''%s'',address:''%s'')',name, age, gender, address) person_information
FROM person
ORDER BY person_information;

-- ex05
SELECT (SELECT name FROM person WHERE id = person_order.person_id ) AS name
FROM person_order
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18) AND order_date = '2022-01-07';

-- ex06
SELECT
   (SELECT name FROM person WHERE id = o.person_id) AS name,
   CASE WHEN (SELECT name FROM person WHERE id = o.person_id) = 'Denis' THEN true
        ELSE false
   END AS check_name
FROM person_order o
WHERE (o.menu_id = 13 OR o.menu_id = 14 OR o.menu_id = 18) AND o.order_date = '2022-01-07';

-- ex07
SELECT id, name,
    CASE WHEN age >= 10 AND age <= 20 THEN 'interval #1'
         WHEN age > 20 AND age < 24 THEN 'interval #2'
         ELSE 'interval #3'
    END AS interval_info
FROM person
ORDER BY interval_info;

-- ex08
SELECT * FROM person_order
WHERE id % 2 = 0
ORDER BY id;

-- ex09
SELECT (SELECT pe.name FROM person pe WHERE pe.id = pv.person_id) AS person_name,
        (SELECT pi.name FROM pizzeria pi WHERE pi.id = pv.pizzeria_id) AS pizzeria_name
FROM (SELECT person_id, pizzeria_id FROM person_visits WHERE visit_date BETWEEN '2022-01-07' AND '2022-01-09') AS pv
ORDER BY person_name, pizzeria_name DESC;