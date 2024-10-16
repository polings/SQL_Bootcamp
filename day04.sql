-- Изучение использования View и Materialized View

-- Представление — это непрерывный объект с теми же данными, что и в базовой таблице(ах), которые используются для создания этого представления.
-- Materialized View — это дискретный объект, обновляется на основе «событийного триггера» (например, расписания). Этот объект всегда отстает от фактических данных в базовых таблицах.

-- Создание представлений на основе фильтрации по полу человека.
CREATE VIEW v_persons_female AS
SELECT * FROM person WHERE gender = 'female';

CREATE VIEW v_persons_male AS
SELECT * FROM person WHERE gender = 'male';

-- Полуение женских и мужских имен в одном списке.
(SELECT name FROM v_persons_female)
UNION
(SELECT name FROM v_persons_male)
ORDER BY name;

-- Представление, которое хранит сгенерированные даты с 1 по 31 января 2022 года.
CREATE VIEW v_generated_dates AS
SELECT generate_series(timestamp '2022-01-01', '2022-01-31', '1 day')::date AS generated_date
ORDER BY 1;

-- Получение дней без посещений в январе 2022 года.
SELECT generated_date AS missing_date
FROM person_visits pv
RIGHT JOIN v_generated_dates
ON generated_date = pv.visit_date
WHERE pv.visit_date IS NULL
ORDER BY 1;

-- Получение «симметричного объединения» по формуле (R - S)∪(S - R), где R — таблица person_visits для 2 января 2022 г., S — таблица person_visits на 6 января 2022 г.
CREATE VIEW v_symmetric_union AS
(SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-02'
EXCEPT
SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-06')
UNION
(SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-06'
EXCEPT
SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-02')
ORDER BY 1;

-- Представление, которое возвращает заказы человека и вычисляемый столбец discount_price (с примененной скидкой 10%).
CREATE VIEW v_price_with_discount AS
SELECT p.name, m.pizza_name, m.price, ROUND(m.price - m.price * 0.1) AS discount_price
FROM menu m
JOIN person_order po ON m.id = po.menu_id
JOIN person p ON po.person_id = p.id
ORDER BY name, pizza_name;

-- Материализованное представление с пиццериями, которые Дмитрий посетил 8 января 2022 года и стоимостью пиццы менее чем за 800 рублей.
CREATE MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS
SELECT pi.name
FROM pizzeria pi
JOIN person_visits pv ON pi.id = pv.pizzeria_id AND visit_date = '2022-01-08'
JOIN person p ON pv.person_id = p.id AND p.name = 'Dmitriy'
JOIN menu m ON pi.id = m.pizzeria_id AND m.price < 800;

-- Добавление новых данных о посещениях и обновление материализованного представления.
INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) + 1 FROM person_visits),
        (SELECT id FROM person WHERE name = 'Dmitriy'),
        (SELECT pi.id FROM pizzeria pi
         JOIN menu m ON pi.id = m.pizzeria_id AND m.price < 800
         WHERE pi.name != 'Papa Johns'
         LIMIT 1), '2022-01-08');
REFRESH MATERIALIZED VIEW mv_dmitriy_visits_and_eats;

-- Удаление всех созданных представлений.
DROP VIEW v_price_with_discount, v_generated_dates, v_persons_female, v_persons_male, v_symmetric_union;
DROP MATERIALIZED VIEW mv_dmitriy_visits_and_eats;