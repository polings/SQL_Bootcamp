-- Изучение использования различных JOIN'ов

-- ex00
SELECT pi.name, pi.rating FROM pizzeria pi
LEFT JOIN public.person_visits pv on pi.id = pv.pizzeria_id
WHERE pv.id IS NULL;

-- ex01
SELECT md.missing_date
FROM person_visits pv
RIGHT JOIN (SELECT generate_series(timestamp '2022-01-01', '2022-01-10', '1 day')::date AS missing_date) md
ON md.missing_date = pv.visit_date AND (pv.person_id = 1 OR pv.person_id = 2)
WHERE pv.visit_date IS NULL
ORDER BY 1;

-- ex02
SELECT COALESCE(p.name, '-') AS person_name, pv.visit_date AS visit_date, COALESCE(pi.name, '-') AS pizzeria_name
FROM (SELECT * FROM person_visits WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-03') pv
FULL JOIN pizzeria pi ON pv.pizzeria_id = pi.id
FULL JOIN person p ON pv.person_id = p.id
ORDER BY 1, 2, 3;

-- ex03
WITH md AS
    (SELECT generate_series(timestamp '2022-01-01', '2022-01-10', '1 day')::date AS missing_date)
SELECT md.missing_date
FROM person_visits pv
RIGHT JOIN md
ON md.missing_date = pv.visit_date AND (pv.person_id = 1 OR pv.person_id = 2)
WHERE pv.visit_date IS NULL
ORDER BY 1;

-- ex04
SELECT m.pizza_name, pi.name AS pizzeria_name, m.price
FROM menu m
JOIN pizzeria pi ON m.pizzeria_id = pi.id AND (m.pizza_name = 'mushroom pizza' OR m.pizza_name = 'pepperoni pizza')
ORDER BY 1, 2;

-- ex05
SELECT name FROM person
WHERE age > 25 AND gender = 'female'
ORDER BY name;

-- ex06
SELECT m.pizza_name, pi.name AS pizzeria_name
FROM menu m
JOIN person_order po ON po.menu_id = m.id
JOIN person p ON p.id = po.person_id AND p.name IN ('Denis', 'Anna')
JOIN pizzeria pi ON m.pizzeria_id = pi.id
ORDER BY 1, 2;

-- ex07
SELECT pi.name AS pizzeria_name
FROM pizzeria pi
JOIN person_visits pv ON pv.pizzeria_id = pi.id AND visit_date = '2022-01-08'
JOIN person p ON p.id = pv.person_id AND p.name = 'Dmitriy'
JOIN menu m ON m.pizzeria_id = pi.id AND price < 800;

-- ex08
SELECT p.name
FROM person p
JOIN person_order po ON po.person_id = p.id
JOIN menu m ON m.id = po.menu_id AND m.pizza_name IN ('pepperoni pizza', 'mushroom pizza')
WHERE p.gender = 'male' AND p.address IN ('Moscow', 'Samara')
ORDER BY 1 DESC;

-- ex09
SELECT p.name
FROM person p
JOIN person_order po ON po.person_id = p.id
JOIN menu m ON m.id = po.menu_id
WHERE p.gender = 'female'
GROUP BY p.name
HAVING STRING_AGG(m.pizza_name, ',') LIKE '%cheese%' AND STRING_AGG(m.pizza_name, ',') LIKE '%pepperoni%'
ORDER BY 1;

-- ex10
SELECT p1.name AS person_name1, p2.name AS person_name2, p1.address AS common_address
FROM person p1, person p2
WHERE p1.address = p2.address AND p1.id > p2.id
ORDER BY 1, 2, 3;