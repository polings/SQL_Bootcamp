-- Добавление новой бизнес логики в базу данных

-- Сreate a new relational table (please set a name person_discounts).
CREATE TABLE person_discounts
( id bigint primary key,
  person_id bigint,
  pizzeria_id bigint,
  discount numeric,
  constraint fk_person_discounts_person_id foreign key (person_id) references person(id),
  constraint fk_person_discounts_pizzeria_id foreign key (pizzeria_id) references pizzeria(id)
)

-- Fill person_discounts table with new records.
INSERT INTO person_discounts
SELECT row_number() OVER () AS id, po.person_id, m.pizzeria_id,
       CASE WHEN count(*) = 1 THEN 10.5
            WHEN count(*) = 2 THEN 22
            ELSE 30
       END
FROM person_order po
JOIN menu m ON m.id = po.menu_id
GROUP BY po.person_id, m.pizzeria_id;

-- Return orders with actual price and price with applied discount for each person in the corresponding pizzeria restaurant.
SELECT p.name, m.pizza_name, m.price, m.price * (1 - pd.discount / 100) AS discount_price, pi.name AS pizzeria_name
FROM menu m
JOIN person_order po ON m.id = po.menu_id
JOIN person p ON po.person_id = p.id
JOIN person_discounts pd ON p.id = pd.person_id
JOIN pizzeria pi ON pd.pizzeria_id = pi.id
ORDER BY p.name, pizza_name;

-- Create a multicolumn unique index that prevents duplicates of pair values person and pizzeria identifiers.
SET ENABLE_SEQSCAN = OFF;
CREATE UNIQUE INDEX idx_person_discounts_unique ON person_discounts (person_id, pizzeria_id);
EXPLAIN ANALYZE
SELECT person_id, pizzeria_id FROM person_discounts
WHERE person_id = 4 AND discount = 10.5;

-- Add the following constraint rules for existing columns of the person_discounts table.
ALTER TABLE person_discounts
    ADD CONSTRAINT ch_nn_person_id CHECK (person_id IS NOT NULL),
    ADD CONSTRAINT ch_nn_pizzeria_id CHECK (pizzeria_id IS NOT NULL),
    ADD CONSTRAINT ch_nn_discount CHECK (discount IS NOT NULL),
    ALTER COLUMN discount SET DEFAULT 0,
    ADD CONSTRAINT ch_range_discount CHECK (discount BETWEEN 0 AND 100);

-- Add comments for the table and table's columns.
COMMENT ON TABLE person_discounts IS 'Personal discounts information. '
                                     'It is aimed to provide personal discounts for people from one side and pizzeria restaurants from other';
COMMENT ON COLUMN person_discounts.id IS 'Identifier of a record';
COMMENT ON COLUMN person_discounts.person_id IS 'Identifier of a person';
COMMENT ON COLUMN person_discounts.pizzeria_id IS 'Identifier of a pizzeria';
COMMENT ON COLUMN person_discounts.discount IS 'A value of discount in percent';

-- Create a Database Sequence and set a default value for id attribute of person_discounts table to take a value from seq_person_discounts each time automatically.
CREATE SEQUENCE seq_person_discounts START 1;
ALTER TABLE person_discounts ALTER COLUMN id SET DEFAULT nextval('seq_person_discounts');
SELECT setval('seq_person_discounts', (SELECT max(id) FROM person_discounts));