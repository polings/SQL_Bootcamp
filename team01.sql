-- Знакомство с DWH и как создаются ETL процессы.

-- Создание таблиц для выполнения задания.
create table "user"
(id bigint primary key ,
 name varchar,
 lastname varchar);

insert into "user" values (1,'Иван', 'Иванов');
insert into "user" values (2,'Петр', null);
insert into "user" values (3, null, 'Сидоров');

create table currency(
    id bigint not null ,
    name varchar not null ,
    rate_to_usd numeric,
    updated timestamp
);

insert into currency values (100, 'EUR', 0.9, '2022-03-03 13:31');
insert into currency values (100, 'EUR', 0.89, '2022-03-02 12:31');
insert into currency values (100, 'EUR', 0.87, '2022-03-02 08:00');
insert into currency values (100, 'EUR', 0.9, '2022-03-01 15:36');
insert into currency values (200, 'USD', 1, '2022-03-03 13:31');
insert into currency values (200, 'USD', 1, '2022-03-02 12:31');
insert into currency values (300, 'JPY', 0.0087, '2022-03-03 13:31');
insert into currency values (300, 'JPY', 0.0079, '2022-03-01 13:31');

create table balance
(user_id bigint,
 money numeric,
 type integer,
 currency_id integer,
 updated timestamp);

insert into balance values (4, 120,1, 200, '2022-01-01 01:31');
insert into balance values (4, 120,0, 300, '2022-01-01 01:31');
insert into balance values (1, 20,1, 100, '2022-01-01 13:31');
insert into balance values (1, 200,1, 100, '2022-01-09 13:31');
insert into balance values (1, 190,1, 100, '2022-01-10 13:31');
insert into balance values (2, 100,2, 210, '2022-01-09 13:31');
insert into balance values (2, 103,2, 210, '2022-01-10 13:31');
insert into balance values (3, 50,0, 100, '2022-01-09 13:31');
insert into balance values (3, 500,1, 200, '2022-01-09 13:31');
insert into balance values (3, 500,2, 300, '2022-01-09 13:31');


--ex00
-- Проблема:
-- Данные в таблицах не согласованы и возможные значения NULL для имени и фамилии в таблице «User».
-- Напишите SQL-выражение, которое возвращает общий объем (сумму всех денег) транзакций с баланса пользователя, агрегированного по пользователю и типу баланса. 
-- Обратите внимание, что все данные должны быть обработаны, включая данные с аномалиями. 
WITH currency_rate AS (
    SELECT * FROM currency
         WHERE updated = (SELECT max(updated) FROM currency)
), user_balance AS (
    SELECT COALESCE(u.name, 'not defined') AS name, COALESCE(u.lastname, 'not defined') AS lastname,
           b.type, SUM(b.money) AS volume, b.currency_id
    FROM "user" u
    FULL JOIN balance b ON u.id = b.user_id
    GROUP BY u.name, u.lastname, b.type, b.currency_id
)
SELECT ub.name, ub.lastname, ub.type, ub.volume,
       COALESCE(cr.name, 'not defined') AS currency_name, COALESCE(cr.rate_to_usd, 1) AS last_rate_to_usd,
       ub.volume * COALESCE(cr.rate_to_usd, 1) AS total_volume_in_usd
FROM user_balance ub
FULL JOIN currency_rate cr ON cr.id = ub.currency_id
ORDER BY 1 DESC, 2, 3;


--ex01
-- Напишите запрос, который возвращает всех пользователей, все транзакции баланса с названием валюты и рассчитанным значением валюты в долларах США на ближайший день.
WITH cte AS (
    SELECT b.user_id, b.money, b.currency_id,
           CASE
               WHEN (SELECT max(c.updated) FROM currency c WHERE b.currency_id = c.id AND c.updated <= b.updated) IS NOT NULL
                    THEN (SELECT max(c.updated) FROM currency c WHERE b.currency_id = c.id AND c.updated <= b.updated)
               ELSE (SELECT min(c.updated) FROM currency c WHERE b.currency_id = c.id AND c.updated >= b.updated)
           END AS updated
    FROM balance b
)
SELECT COALESCE(u.name, 'not defined') AS name, COALESCE(u.lastname, 'not defined') AS lastname ,
                c.name AS currency_name, cte.money * c.rate_to_usd AS currency_in_usd
FROM cte
RIGHT JOIN currency c ON c.id = cte.currency_id
LEFT JOIN "user" u ON cte.user_id = u.id
WHERE c.updated = cte.updated
ORDER BY 1 DESC, 2, 3;