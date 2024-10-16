-- Изучение как и когда создавать индексы в базе данных.

-- Сreate a simple BTree index for every foreign key.
CREATE INDEX idx_menu_pizzeria_id
ON menu (pizzeria_id);

CREATE INDEX idx_person_order_person_id
ON person_order (person_id);

CREATE INDEX idx_person_order_menu_id
ON person_order (menu_id);

CREATE INDEX idx_person_visits_person_id
ON person_visits (person_id);

CREATE INDEX idx_person_visits_pizzeria_id
ON person_visits (pizzeria_id);

-- Provide proof that your indexes are working for your SQL. Use EXPLAIN ANALYZE command.
SET ENABLE_SEQSCAN = OFF;
EXPLAIN ANALYZE
SELECT m.pizza_name, pi.name AS pizzeria_name
FROM menu m
JOIN pizzeria pi ON pi.id = m.pizzeria_id;

-- Create a functional B-Tree index for the column name. 
-- Index should contain person names in upper case.
SET ENABLE_SEQSCAN = OFF;
CREATE INDEX idx_person_name ON person (upper(name));
EXPLAIN ANALYZE
SELECT * FROM person
WHERE upper(name) = 'KATE';

-- Create a better multicolumn B-Tree index.
SET ENABLE_SEQSCAN = OFF;
CREATE INDEX idx_person_order_multi ON person_order (person_id, menu_id, order_date);
EXPLAIN ANALYZE
SELECT person_id, menu_id,order_date
FROM person_order
WHERE person_id = 8 AND menu_id = 19;

-- Create a unique BTree index on the menu table for pizzeria_id and pizza_name columns.
SET ENABLE_SEQSCAN = OFF;
CREATE UNIQUE INDEX idx_menu_unique ON menu (pizzeria_id, pizza_name);
EXPLAIN ANALYZE
SELECT pizzeria_id, pizza_name FROM menu
WHERE pizzeria_id = 1 AND pizza_name = 'sausage pizza';

-- Create a partial unique BTree index on the person_order table for person_id and menu_id attributes with partial uniqueness for order_date column for date ‘2022-01-01’
SET ENABLE_SEQSCAN = OFF;
CREATE UNIQUE INDEX idx_person_order_order_date ON person_order (person_id, menu_id)
WHERE order_date = '2022-01-01';
EXPLAIN ANALYZE
SELECT person_id FROM person_order
WHERE order_date = '2022-01-01' AND menu_id = 9;

-- Create a new BTree index which should improve the “Execution Time” metric of this SQL.
CREATE INDEX idx_1 ON pizzeria (rating);
EXPLAIN ANALYZE
SELECT
    m.pizza_name AS pizza_name,
    max(rating) OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM  menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1,2;