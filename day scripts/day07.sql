-- Изучение работы агрегации данных.

-- Return person identifiers and corresponding number of visits in any pizzerias.
SELECT person_id, count(*) AS count_of_visits
FROM person_visits
GROUP BY person_id
ORDER BY 2 DESC, 1;

-- Return top-4 persons with maximal visits in any pizzerias.
SELECT p.name, count(*) AS count_of_visits
FROM person_visits pv
JOIN person p ON pv.person_id = p.id
GROUP BY p.name
ORDER BY 2 DESC, 1
LIMIT 4;

-- Return 3 favorite restaurants by visits and by orders in one list,
-- add an action_type column with values ‘order’ or ‘visit’, it depends on data from the corresponding table.
(SELECT pi.name, count(*) AS count, 'order' AS action_type
FROM person_order po
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pi ON m.pizzeria_id = pi.id
GROUP BY pi.name
ORDER BY 2 DESC, 1
LIMIT 3)
UNION
(SELECT pi.name, count(*) AS count, 'visit' AS action_type
FROM person_visits pv
JOIN pizzeria pi ON pv.pizzeria_id = pi.id
GROUP BY pi.name
ORDER BY 2 DESC, 1
LIMIT 3)
ORDER BY 3, 2 DESC;

-- Return restaurants that are grouping by visits and by orders and joined with each other by using restaurant name, 
-- calculate a sum of orders and visits for corresponding pizzeria
WITH t AS
((SELECT pi.name, count(*) AS count, 'order' AS action_type
FROM person_order po
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pi ON m.pizzeria_id = pi.id
GROUP BY pi.name
)
UNION
(SELECT pi.name, count(*) AS count, 'visit' AS action_type
FROM person_visits pv
JOIN pizzeria pi ON pv.pizzeria_id = pi.id
GROUP BY pi.name
))
SELECT t.name, sum(t.count) AS total_count
FROM t
GROUP BY t.name
ORDER BY 2 DESC, 1;

-- Return the person name and corresponding number of visits in any pizzerias if the person has visited more than 3 times.
SELECT p.name, count(*) AS count_of_visits
FROM person_visits pv
JOIN person p ON pv.person_id = p.id
GROUP BY p.name
HAVING count(*) > 3;

-- Return a list of unique person names who made orders in any pizzerias.
SELECT DISTINCT p.name
FROM person p
JOIN person_order po ON p.id = po.person_id
ORDER BY 1;

-- Return the amount of orders, average of price, maximum and minimum prices for sold pizza by corresponding pizzeria restaurant.
SELECT pi.name, count(*) AS count_of_orders,
       round(avg(m.price), 2) AS average_price, max(m.price) AS max_price, min(m.price) AS min_price
FROM person_order po
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pi ON pi.id = m.pizzeria_id
GROUP BY pi.name
ORDER BY 1;

-- Return a common average rating (the output attribute name is global_rating) for all restaurants.
SELECT round(avg(rating), 4) AS global_rating FROM pizzeria;

-- Return address, pizzeria name and amount of persons’ orders.
SELECT p.address, pi.name, count(*) AS count_of_orders
FROM person_order po
JOIN person p ON po.person_id = p.id
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pi ON m.pizzeria_id = pi.id
GROUP BY p.address, pi.name
ORDER BY 1, 2;

-- Return aggregated information by person’s address, 
-- the result of “Maximal Age - (Minimal Age  / Maximal Age)” that is presented as a formula column, 
-- next one is average age per address 
-- and the result of comparison between formula and average columns (other words, if formula is greater than  average then True, otherwise False value).
SELECT address, round(max(age) - (min(age) / max(age::numeric)), 2) AS formula, round(avg(age), 2) AS average,  max(age) - (min(age) / max(age)) > avg(age)
FROM person
GROUP BY address
ORDER BY 1;