-- Изучение работы функций и триггеров

-- ex00
-- Create a table person_audit, create a Database Trigger Function that should process INSERT DML traffic and
-- make a copy of a new row to the person_audit table.
CREATE TABLE person_audit
( created timestamptz default current_timestamp not null,
  type_event char(1) default 'I' not null,
  row_id  bigint not null,
  name varchar not null,
  age integer not null default 10,
  gender varchar default 'female' not null ,
  address varchar,
  constraint ch_type_event check ( type_event IN ('I', 'U', 'D'))
);

CREATE FUNCTION fnc_trg_person_insert_audit() RETURNS trigger
AS '
BEGIN
    IF (TG_OP = ''INSERT'') THEN
        INSERT INTO person_audit (row_id, name, age, gender, address) VALUES (NEW.*);
    END IF;
    RETURN NULL;
END;
'
LANGUAGE plpgsql;

CREATE TRIGGER trg_person_insert_audit AFTER INSERT ON person
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_insert_audit();

INSERT INTO person(id, name, age, gender, address) VALUES (10,'Damir', 22, 'male', 'Irkutsk');

-- ex01
-- Handle all UPDATE traffic on the person table.
CREATE FUNCTION fnc_trg_person_update_audit() RETURNS trigger
AS '
BEGIN
    IF (TG_OP = ''UPDATE'') THEN
        INSERT INTO person_audit (type_event, row_id, name, age, gender, address) VALUES (''U'', OLD.*);
    END IF;
    RETURN NULL;
END;
'
LANGUAGE plpgsql;

CREATE TRIGGER trg_person_update_audit AFTER UPDATE ON person
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_update_audit();

UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;

-- ex02
-- Handle DELETE statements and make a copy of OLD states for all attribute’s values. 
CREATE FUNCTION fnc_trg_person_delete_audit() RETURNS trigger
AS '
BEGIN
    IF (TG_OP = ''DELETE'') THEN
        INSERT INTO person_audit (type_event, row_id, name, age, gender, address) VALUES (''D'', OLD.*);
    END IF;
    RETURN NULL;
END;
'
LANGUAGE plpgsql;

CREATE TRIGGER trg_person_delete_audit AFTER DELETE ON person
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_delete_audit();

DELETE FROM person WHERE id = 10;

-- ex03
-- All DML traffic (INSERT, UPDATE, DELETE) should be handled from the one functional block.
-- Drop old functions.
DROP TRIGGER IF EXISTS trg_person_delete_audit ON person;
DROP TRIGGER IF EXISTS trg_person_update_audit ON person;
DROP TRIGGER IF EXISTS trg_person_insert_audit ON person;

DROP FUNCTION IF EXISTS fnc_trg_person_delete_audit();
DROP FUNCTION IF EXISTS fnc_trg_person_update_audit();
DROP FUNCTION IF EXISTS fnc_trg_person_insert_audit();

TRUNCATE person_audit;

CREATE FUNCTION fnc_trg_person_audit() RETURNS trigger
AS '
BEGIN
    IF (TG_OP = ''DELETE'') THEN
        INSERT INTO person_audit (type_event, row_id, name, age, gender, address) VALUES (''D'', OLD.*);
    ELSIF (TG_OP = ''UPDATE'') THEN
        INSERT INTO person_audit (type_event, row_id, name, age, gender, address) VALUES (''U'', OLD.*);
    ELSIF (TG_OP = ''INSERT'') THEN
        INSERT INTO person_audit (row_id, name, age, gender, address) VALUES (NEW.*);
    END IF;
    RETURN NULL;
END;
'
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_person_audit AFTER DELETE OR UPDATE OR INSERT ON person
FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_audit();

INSERT INTO person(id, name, age, gender, address)  VALUES (10,'Damir', 22, 'male', 'Irkutsk');
UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;
DELETE FROM person WHERE id = 10;

-- ex04
-- Function that should return female persons and another should return male persons.
CREATE OR REPLACE FUNCTION fnc_persons_male()
RETURNS SETOF person
AS '
  SELECT * FROM person WHERE gender = ''male'';
'
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fnc_persons_female()
RETURNS SETOF person
AS '
  SELECT * FROM person WHERE gender = ''female'';
'
LANGUAGE SQL;

SELECT * FROM fnc_persons_male();
SELECT * FROM fnc_persons_female();

-- ex05
-- Function should have an IN parameter pgender with default value = ‘female’.
DROP FUNCTION IF EXISTS fnc_persons_male();
DROP FUNCTION IF EXISTS fnc_persons_female();

CREATE OR REPLACE FUNCTION fnc_persons(pgender varchar DEFAULT 'female')
RETURNS SETOF person
AS '
  SELECT * FROM person WHERE gender = $1;
'
LANGUAGE SQL;

select * from fnc_persons(pgender := 'male');
select * from fnc_persons();

-- ex06
-- Function that finds the names of pizzerias which person (IN pperson parameter with default value is ‘Dmitriy’)
-- visited and in which he could buy pizza for less than the given sum in rubles (IN pprice parameter with default value is 500)
-- on the specific date (IN pdate parameter with default value is 8th of January 2022).
CREATE FUNCTION fnc_person_visits_and_eats_on_date(pperson varchar DEFAULT 'Dmitriy',
                                                   pprice numeric DEFAULT 500,
                                                   pdate date DEFAULT '2022-01-08') RETURNS TABLE (pizzeria_name varchar)
AS '
BEGIN
   RETURN QUERY SELECT pi.name
                FROM pizzeria pi
                JOIN menu m ON pi.id = m.pizzeria_id
                JOIN person_visits pv ON pi.id = pv.pizzeria_id
                JOIN person p ON p.id = pv.person_id
                WHERE p.name = $1 AND m.price < $2 AND pv.visit_date = $3;
END;
'
LANGUAGE plpgsql;

select * from fnc_person_visits_and_eats_on_date(pprice := 800);
select * from fnc_person_visits_and_eats_on_date(pperson := 'Anna',pprice := 1300,pdate := '2022-01-01');

-- ex07
-- Function that has an input parameter is an array of numbers and the function should return a minimum value.
CREATE OR REPLACE FUNCTION func_minimum(VARIADIC arr numeric[])
RETURNS numeric
AS '
    SELECT min($1[i]) FROM generate_subscripts($1, 1) g(i);
'
LANGUAGE SQL;

SELECT func_minimum(VARIADIC arr => ARRAY[10.0, 6.0, 5.0, 4.4]);

-- ex08
-- Function that has an input parameter pstop with type integer (by default is 10) 
-- and the function output is a table with all Fibonacci numbers less than pstop.
CREATE OR REPLACE FUNCTION fnc_fibonacci(pstop integer default 10)
RETURNS TABLE (fnc_fibonacci integer)
AS '
    WITH RECURSIVE fibonacci AS (
      SELECT 0 AS cur, 1 AS prev, 1 AS n
      UNION
      SELECT cur + prev,
             cur,
             n + 1
      FROM fibonacci
      WHERE cur < pstop
    )
    SELECT prev as fibonacci_sequence FROM fibonacci;
'
LANGUAGE SQL;

select * from fnc_fibonacci(100);
select * from fnc_fibonacci();