-- Изучение, как база данных работает с транзакциями и уровнями изоляции. 

-- Аномалии БД:
-- Lost Update Anomaly(Потерянное обновление)-ситуация, когда при одновременном изменении одного блока данных разными транзакциями одно из изменений теряется.
-- Dirty Reads Anomaly(«Грязное» чтение)-чтение данных, добавленных или изменённых транзакцией, которая впоследствии не подтвердится (откатится).
-- Non-repeatable Reads Anomaly(Неповторяющееся чтение)-ситуация, когда при повторном чтении в рамках одной транзакции ранее прочитанные данные оказываются изменёнными.
-- Phantom Read Anomaly(Чтение «фантомов»)-ситуация, когда при повторном чтении в рамках одной транзакции одна и та же выборка дает разные множества строк.

-- Уровни изоляции БД:
-- Read uncommitted-если несколько параллельных транзакций пытаются изменять одну и ту же строку таблицы, то в окончательном варианте строка будет иметь значение, определённое всем набором успешно выполненных транзакций.
-- Read committed-чтение зафиксированных данных
-- Repeatable read-читающая транзакция «не видит» изменения данных, которые были ею ранее прочитаны. При этом никакая другая транзакция не может изменять данные, читаемые текущей транзакцией, пока та не окончена.
-- Serializable-транзакции полностью изолируются друг от друга. Результат выполнения нескольких параллельных транзакций должен быть таким, как если бы они выполнялись последовательно. 

-- ex00
-- Provide a proof that your parallel session can’t see your changes until you will make a COMMIT;
-- Session #1
BEGIN;
-- BEGIN
UPDATE pizzeria SET rating = 5 WHERE name = 'Pizza Hut';
-- UPDATE 1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
--  id |   name    | rating
-- ----+-----------+--------
--   1 | Pizza Hut |      5
-- (1 row)

BEGIN;
-- BEGIN
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
--  id |   name    | rating
-- ----+-----------+--------
--   1 | Pizza Hut |    4.6
-- (1 row)

-- Session #1
COMMIT;
-- COMMIT

-- Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
--  id |   name    | rating
-- ----+-----------+--------
--   1 | Pizza Hut |      5
-- (1 row)


-- ex01
-- Check Lost Update Anomaly, “read committed” isolation level.
-- Session #1
BEGIN;
-- BEGIN

-- Session #2
BEGIN;
-- BEGIN

-- Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--       5
-- (1 row)

-- Session #2
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--       5
-- (1 row)

-- Session #1
UPDATE pizzeria SET rating = 4 WHERE name = 'Pizza Hut';
-- UPDATE 1

-- Session #2
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';

-- Session #1
COMMIT;
-- COMMIT

-- Session #2
-- UPDATE 1
COMMIT;
-- COMMIT

-- Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)

-- Session #2
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)


-- ex02
-- Lost Update for Repeatable Read, "REPEATABLE READ" isolation level
-- Session #1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- BEGIN

-- Session #2
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- BEGIN

-- Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)

-- Session #2
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)

-- Session #1
UPDATE pizzeria SET rating = 4 WHERE name = 'Pizza Hut';
-- UPDATE 1

-- Session #2
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
-- ERROR:  could not serialize access due to concurrent update

-- Session #1
COMMIT;
-- COMMIT

-- Session #2
COMMIT;
-- ROLLBACK

-- Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--       4
-- (1 row)

-- Session #2
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--       4
-- (1 row)


-- ex03
-- Non-Repeatable Reads Anomaly, "READ COMMITTED" isolation level.
-- Session #1
BEGIN;
-- BEGIN

-- Session #2
BEGIN;
-- BEGIN

-- Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--       4
-- (1 row)

-- Session #2
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
-- UPDATE 1
COMMIT;
-- COMMIT

-- Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)
COMMIT;
-- COMMIT
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)

-- Session #2
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)


-- ex04
-- Non-Repeatable Reads for Serialization, SERIALIZABLE isolation level. 
-- Session #1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- BEGIN

-- Session #2
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- BEGIN

-- Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)

-- Session #2
UPDATE pizzeria SET rating = 3.0 WHERE name = 'Pizza Hut';
-- UPDATE 1
COMMIT;
-- COMMIT

-- Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.6
-- (1 row)
COMMIT;
-- COMMIT
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.0
-- (1 row)

-- Session #2
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut';
--  rating
-- --------
--     3.0
-- (1 row)


-- ex05
-- Phantom Reads Anomaly, "READ COMMITTED" isolation level. 
-- Session #1
BEGIN;
-- BEGIN

-- Session #2
BEGIN;
-- BEGIN

-- Session #1
SELECT SUM(rating) FROM pizzeria;
--  sum
-- ------
--  21.9
-- (1 row)

-- Session #2
UPDATE pizzeria SET rating = 1 WHERE name = 'Pizza Hut';
-- UPDATE 1
COMMIT;
-- COMMIT

-- Session #1
SELECT SUM(rating) FROM pizzeria;
--  sum
-- ------
--  19.9
-- (1 row)
COMMIT;
-- COMMIT
SELECT SUM(rating) FROM pizzeria;
--  sum
-- ------
--  19.9
-- (1 row)

-- Session #2
SELECT SUM(rating) FROM pizzeria;
--  sum
-- ------
--  19.9
-- (1 row)


-- ex06
-- Phantom Reads for Repeatable Read, "REPEATABLE READ" isolation level. 
-- Session #1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- BEGIN

-- Session #2
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- BEGIN

-- Session #1
SELECT SUM(rating) FROM pizzeria;
--  sum
-- ------
--  19.9
-- (1 row)

-- Session #2
UPDATE pizzeria SET rating = 5 WHERE name = 'Pizza Hut';
-- UPDATE 1
COMMIT;
-- COMMIT

-- Session #1
SELECT SUM(rating) FROM pizzeria;
--  sum
-- ------
--  19.9
-- (1 row)
COMMIT;
-- COMMIT
SELECT SUM(rating) FROM pizzeria;
--  sum
-- ------
--  23.9
-- (1 row)

-- Session #2
SELECT SUM(rating) FROM pizzeria;
--  sum
-- ------
--  23.9
-- (1 row)


-- ex07
-- Deadlock, any level
-- Session #1
BEGIN;
-- BEGIN

-- Session #2
BEGIN;
-- BEGIN

-- Session #1
UPDATE pizzeria SET rating = 3 WHERE id = 1;
-- UPDATE 1

-- Session #2
UPDATE pizzeria SET rating = 2 WHERE id = 2;
-- UPDATE 1

-- Session #1
UPDATE pizzeria SET rating = 3 WHERE id = 2;
-- UPDATE 1

-- Session #2
UPDATE pizzeria SET rating = 2 WHERE id = 1;
-- ERROR:  deadlock detected
-- DETAIL:  Process 56578 waits for ShareLock on transaction 1652; blocked by process 56417.
-- Process 56417 waits for ShareLock on transaction 1653; blocked by process 56578.
-- HINT:  See server log for query details.
-- CONTEXT:  while updating tuple (0,14) in relation "pizzeria"

-- Session #1
COMMIT;
-- COMMIT

-- Session #2
COMMIT;
-- ROLLBACK