

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS sellers;

CREATE TABLE sellers (
    id           SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    inn          VARCHAR(12),
    rating       DECIMAL(3,2)
);

CREATE TABLE products (
    id           SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    seller_id    INT,                    
    price        DECIMAL(10,2),
    stock        INT
);

CREATE TABLE customers (
    id        SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email     VARCHAR(100),
    phone     VARCHAR(20)
);

CREATE TABLE orders (
    id          SERIAL PRIMARY KEY,
    customer_id INT,                     
    product_id  INT,                    
    quantity    INT,
    total       DECIMAL(10,2),
    order_date  DATE
);



INSERT INTO sellers (company_name, inn, rating) VALUES
    ('ООО "ТехноМир"',    '770123456789', 4.8),
    ('ИП Иванов А.А.',    '770987654321', 4.2),
    ('ООО "ЭкоПродукт"',  '770555444333', 4.9),
    ('ООО "СтройМастер"', '770111222333', 3.7);

INSERT INTO products (product_name, seller_id, price, stock) VALUES
    ('Смартфон Galaxy X',    1,   59990.00, 15),
    ('Ноутбук Pro 15',       1,   89990.00,  8),
    ('Наушники AirSound',    2,   12990.00, 30),
    ('Кофеварка BrewMaster', 3,    8990.00, 12),
    ('Пылесос CleanHome',    3,   15990.00,  5),
    ('Дрель MasterTool',     4,    6490.00, 20),
    ('Товар без продавца',   999,  1000.00,  1);      

INSERT INTO customers (full_name, email, phone) VALUES
    ('Иванов Иван Иванович',     'ivanov@mail.ru',     '+7-999-111-22-33'),
    ('Петрова Анна Сергеевна',   'petrova@mail.ru',    '+7-999-222-33-44'),
    ('Сидоров Пётр Алексеевич',  'sidorov@mail.ru',    '+7-999-333-44-55'),
    ('Кузнецова Мария Игоревна', 'kuznetsova@mail.ru', '+7-999-444-55-66');


INSERT INTO orders (customer_id, product_id, quantity, total, order_date) VALUES
    (1,   1, 1, 59990.00, '2026-09-01'),
    (1,   3, 2, 25980.00, '2026-09-02'),
    (2,   2, 1, 89990.00, '2026-09-03'),
    (3,   4, 1,  8990.00, '2026-09-04'),
    (3,   5, 1, 15990.00, '2026-09-05'),
    (4,   6, 3, 19470.00, '2026-09-06'),
    (999, 1, 1, 59990.00, '2026-09-07');             


SELECT * FROM sellers   ORDER BY id;
SELECT * FROM products  ORDER BY id;
SELECT * FROM customers ORDER BY id;
SELECT * FROM orders    ORDER BY id;



SELECT
    p.id           AS id_товара,
    p.product_name AS товар,
    p.price        AS цена,
    s.company_name AS продавец
FROM products p
LEFT JOIN sellers s ON p.seller_id = s.id
ORDER BY p.id;


SELECT
    s.id           AS id_продавца,
    s.company_name AS компания,
    p.product_name AS товар,
    p.price        AS цена
FROM products p
RIGHT JOIN sellers s ON p.seller_id = s.id
ORDER BY s.id;


INSERT INTO sellers (company_name, inn, rating)
VALUES ('ООО "НовыйПродавец"', '770999888777', 4.0);

SELECT
    s.id           AS id_продавца,
    s.company_name AS компания,
    p.product_name AS товар,
    p.price        AS цена
FROM products p
RIGHT JOIN sellers s ON p.seller_id = s.id
ORDER BY s.id;



SELECT p.id, p.product_name, p.seller_id
FROM products p
LEFT JOIN sellers s ON p.seller_id = s.id
WHERE s.id IS NULL;



SELECT s.id, s.company_name
FROM products p
RIGHT JOIN sellers s ON p.seller_id = s.id
WHERE p.id IS NULL;

SELECT s.id, s.company_name
FROM sellers s
LEFT JOIN products p ON p.seller_id = s.id
WHERE p.id IS NULL;


SELECT o.id, o.customer_id, o.product_id, o.total, o.order_date
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id
WHERE c.id IS NULL;

SELECT
    p.id           AS id_товара,
    p.product_name AS товар,
    p.seller_id    AS seller_id_в_товаре,
    s.id           AS id_продавца,
    s.company_name AS продавец
FROM products p
FULL JOIN sellers s ON p.seller_id = s.id
WHERE p.id IS NULL OR s.id IS NULL;

DELETE FROM products p
WHERE NOT EXISTS (SELECT 1 FROM sellers s WHERE s.id = p.seller_id);


SELECT * FROM products WHERE product_name = 'Товар без продавца';

INSERT INTO products (product_name, seller_id, price, stock)
VALUES ('Товар без продавца', 999, 1000.00, 1);


UPDATE products
SET seller_id = 1
WHERE product_name = 'Товар без продавца' AND seller_id = 999;


SELECT p.id, p.product_name
FROM products p
LEFT JOIN sellers s ON p.seller_id = s.id
WHERE s.id IS NULL;

UPDATE products
SET seller_id = 999
WHERE product_name = 'Товар без продавца';


INSERT INTO sellers (id, company_name, inn, rating)
VALUES (999, 'ООО "Восстановленный продавец"', '770000000999', 3.0);


SELECT p.id, p.product_name
FROM products p
LEFT JOIN sellers s ON p.seller_id = s.id
WHERE s.id IS NULL;

INSERT INTO customers (id, full_name, email, phone)
VALUES (999, 'Восстановленный покупатель', NULL, NULL);


SELECT p.*
FROM products p
LEFT JOIN sellers s ON p.seller_id = s.id
WHERE s.id IS NULL;


SELECT o.*
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id
WHERE c.id IS NULL;


SELECT o.*
FROM orders o
LEFT JOIN products p ON o.product_id = p.id
WHERE p.id IS NULL;




SELECT
    p.product_name AS товар,
    p.price        AS цена,
    s.company_name AS продавец,
    s.rating       AS рейтинг
FROM products p
JOIN sellers s ON p.seller_id = s.id
ORDER BY s.rating DESC, p.price;


SELECT
    s.company_name AS компания,
    COUNT(p.id)    AS количество_товаров
FROM sellers s
LEFT JOIN products p ON p.seller_id = s.id
GROUP BY s.id, s.company_name
ORDER BY количество_товаров DESC;


SELECT
    c.full_name                AS покупатель,
    COUNT(o.id)                AS количество_заказов,
    COALESCE(SUM(o.total), 0)  AS общая_сумма
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.full_name
ORDER BY общая_сумма DESC;


SELECT p.id, p.product_name, p.price, p.stock
FROM products p
LEFT JOIN orders o ON o.product_id = p.id
WHERE o.id IS NULL;

SELECT c.id, c.full_name, c.email
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL;

-- RIGHT JOIN: все продавцы с товарами
SELECT s.id, s.company_name, p.product_name
FROM products p
RIGHT JOIN sellers s ON p.seller_id = s.id
ORDER BY s.id, p.id;


SELECT s.id, s.company_name, p.product_name
FROM sellers s
LEFT JOIN products p ON p.seller_id = s.id
ORDER BY s.id, p.id;

ALTER TABLE products
    ADD CONSTRAINT fk_products_sellers
    FOREIGN KEY (seller_id) REFERENCES sellers(id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE orders
    ADD CONSTRAINT fk_orders_products
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

