# Overview SQL Bootcamp

Самостоятельное изучение языка SQL и СУБД PostgreSQL по заданиям из буткемпа.
Буткемп состоит из 10 индивидуальных дней с заданиями объединенными по разным разделам языка и 2 групповых проектов. \
Данные для создания и заполнения таблиц БД находятся в папке datasets, скрипт *data_base_model.sql*.
## Логический вид модели БД

![SQL1](./misc/images/schema.png)

1. [Individual days](#individual-days) \
   1.1 [Day 00](#day-00) \
   1.2 [Day 01](#day-01) \
   1.3 [Day 02](#day-02) \
   1.4 [Day 03](#day-03) \
   1.5 [Day 04](#day-04) \
   1.6 [Day 05](#day-05) \
   1.7 [Day 06](#day-06) \
   1.8 [Day 07](#day-07) \
   1.9 [Day 08](#day-08) \
   1.10 [Day 09](#day-09)
2. [Team projects](#team-projects)  \
   1.1 [Project 00](#project-00) \
   1.2 [Project 01](#project-01)

## Individual days
Все скрипты по дням лежат в папке *day scripts*.
#### Day 00
Изучение синтаксиса SELECT, использование подзапросов. Знакомство с реляционной моделью данных.
#### Day 01
Изучение операторов множеств UNION[ALL], EXCEPT[ALL], INTERSECT[ALL], а также знакомство с различными видами JOIN'ов.
#### Day 02
Изучение принципов работы JOIN в SQL. Знакомство с некоторыми встроенными функциями Postgres.
#### Day 03
Изменение данных на основе языка DML. Изучение принципов работы INSERT, UPDATE, DELETE в базе данных.
#### Day 04
Использования View и Materialized View (virtual view и physical snapshot of data).
#### Day 05
Обучение работы с индексами в БД. Как, когда и какого типа индексы использовать для таблиц.
#### Day 06
Изучение процесса проектирования хранилища данных. Знакомство с оконными функциями. Добавление новой бизнес-логики в БД.
#### Day 07
Работа с агрегированными данными. Знакомство понятиями DataLake, DataWareHouse.
#### Day 08
Знакомоство с требованиями ACID, аномалиями данных. Изучение, как база данных работает с транзакциями и уровнями изоляции. 
#### Day 09
Написание функций и триггеров. Логгирование DML-операций. Знакомство с последовательностями.

## Team projects
Все скрипты по дням лежат в папке *team projects*.
#### Project 00
Изучение рекурсивных запросов. Решение на SQL задачи коммивояжера.
#### Project 01
Знакомство с DWH и как создаются ETL процессы. Написание запросов и работа с аномалиями в данных.



