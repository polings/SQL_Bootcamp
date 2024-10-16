-- Решение на SQL задачи коммивояжера. Изучение рекурсивных запросов.

-- ex00
-- Есть 4 города (a, b, c и d) и дуги между ними с ценой пути.
CREATE TABLE tour_cost
(
    point1 varchar not null,
    point2 varchar not null,
    cost   integer not null
);

INSERT INTO tour_cost VALUES ('a', 'b', 10);
INSERT INTO tour_cost VALUES ('b', 'a', 10);
INSERT INTO tour_cost VALUES ('a', 'c', 15);
INSERT INTO tour_cost VALUES ('c', 'a', 15);
INSERT INTO tour_cost VALUES ('a', 'd', 20);
INSERT INTO tour_cost VALUES ('d', 'a', 20);
INSERT INTO tour_cost VALUES ('b', 'd', 25);
INSERT INTO tour_cost VALUES ('d', 'b', 25);
INSERT INTO tour_cost VALUES ('c', 'd', 30);
INSERT INTO tour_cost VALUES ('d', 'c', 30);
INSERT INTO tour_cost VALUES ('b', 'c', 35);
INSERT INTO tour_cost VALUES ('c', 'b', 35);

-- Создайте таблицу с именами узлов, используя структуру {point1, point2, cost} и найдите все пути с минимальной стоимостью путешествия, если мы начнем с города "a". 
-- Нужно найти самый дешевый способ посетить все города и вернуться в исходную точку. 
-- Например, путь выглядит так a -> b -> c -> d -> a.
WITH RECURSIVE travel(total_cost, tour, next, count) AS
    (SELECT cost, ARRAY [point1]::VARCHAR[1] AS tour, point2, 1
    FROM tour_cost
    WHERE point1 = 'a'
    UNION
    SELECT t.total_cost + tc.cost, t.tour || tc.point1, point2, count + 1
    FROM travel t
    JOIN tour_cost tc ON tc.point1 = t.next
    WHERE NOT tc.point1 = ANY (t.tour))
SELECT total_cost, (tour || ARRAY ['a']) AS tour
FROM travel
WHERE next = 'a' AND count = 4 AND total_cost =
    (SELECT MIN(total_cost)
    FROM travel
    WHERE next = 'a' AND count = 4);

--ex01
-- Найдите все пути с максимальной стоимостью путешествия.
WITH RECURSIVE travel(total_cost, tour, next, count) AS
    (SELECT cost, ARRAY [point1]::VARCHAR[1] AS tour, point2, 1
    FROM tour_cost
    WHERE point1 = 'a'
    UNION
    SELECT t.total_cost + tc.cost, t.tour || tc.point1, point2, count + 1
    FROM travel t
    JOIN tour_cost tc ON tc.point1 = t.next
    WHERE NOT tc.point1 = ANY (t.tour))
SELECT total_cost, (tour || ARRAY ['a']) AS tour
FROM travel
WHERE next = 'a' AND count = 4 AND (total_cost =
    (SELECT MIN(total_cost)
    FROM travel
    WHERE next = 'a' AND count = 4)
    OR total_cost =
    (SELECT max(total_cost)
    FROM travel
    WHERE next = 'a' AND count = 4))
ORDER BY total_cost, tour;