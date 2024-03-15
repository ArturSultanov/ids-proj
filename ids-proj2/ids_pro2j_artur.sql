/*
IDS - Databázové systémy.
Projekt 2. část - SQL skript pro vytvoření objektů schématu databáze.

Authors:
Kirill Shchetiniuk (xshche05),
Artur Sultanov (xsulta01).
*/


/******************** TABLES DROP ********************/
BEGIN
    -- WARNING: Deleting all existing user's table
    FOR existing_table IN (SELECT table_name FROM user_tables ) LOOP
        IF existing_table.TABLE_NAME in ('ADDRESS',
                                         'ALLERGENS',
                                         'CAR',
                                         'COURIER',
                                         'CUSTOMERS',
                                         'DELIVERYTICKET',
                                         'EMPLOYEE',
                                         'INGREDIENTS',
                                         'ITEMS',
                                         'ITEMS_CONSIST_OF_INGREDIENTS',
                                         'ITEMS_CONTAINS_ALLERGENS',
                                         'ORDERS',
                                         'ORDER_CONTAINS_ITEMS',
                                         'PERSON',
                                         'WORKER_SHIFT',
                                         'WORKINGSHIFT') THEN
            EXECUTE IMMEDIATE 'DROP TABLE ' || existing_table.table_name || ' CASCADE CONSTRAINTS';
        END IF;
    END LOOP;
end;
/

-- Date formatting
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';

/******************** TABLES ********************/

CREATE TABLE Person (
    person_id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name varchar(255) NOT NULL,
    surname varchar(255) NOT NULL
);


-- Customer, is sub type of Person, have a foreign key to Person and order amount starts
-- with 0
CREATE TABLE Customers (
    person_id int PRIMARY KEY,
    order_amount int DEFAULT 0,
    CONSTRAINT fk_customer_person_id
        FOREIGN KEY (person_id)
        REFERENCES Person(person_id)
        ON DELETE CASCADE
);

/*
Table represents the 'Order' entity.
Holds details about customer orders, including a unique order ID,
status, delivery option, date of order, price, and comment.
'Orders' contain 'Items'. For that reason the Item_contains_Allergen associative table is implemented.
*/

CREATE TABLE Orders (
    order_id INT GENERATED BY DEFAULT as identity NOT NULL PRIMARY KEY,
    order_customer_id INT NOT NULL,

    order_status VARCHAR2(50) default 'NEW' not null,
    CONSTRAINT order_status_check CHECK ( order_status in ('NEW', 'IN_PROGRESS', 'COMPLETED', 'ARCHIVED')),

    order_delivery_option VARCHAR2(50) not null,
    CONSTRAINT order_delivery_option_check CHECK ( order_delivery_option in ('COURIER_DELIVERY', 'SELF_PICKUP')),

    order_date DATE not null,
    -- CONSTRAINT order_date_check CHECK (order_date <= sysdate), -- todo:

    order_price DECIMAL default 0 not null,
    CONSTRAINT order_price_check CHECK (order_price >= 0),

    order_comment VARCHAR2(1024),

    CONSTRAINT fk_order_customer_id
        FOREIGN KEY (order_customer_id)
        REFERENCES Customers(person_id)
        on delete CASCADE
);

/*
Table represents the 'Item' entity.
Represents the bakery items for sale, with attributes such as article number, name, description, and price.
'Items' can contain 'Allergens'. For that reason the Items_contains_Allergens associative table is implemented.
'Items' consist of 'Ingredients'. For that reason the Items_consist_of_Ingredients associative table is implemented.
*/
CREATE TABLE Items (
    item_article_number INT generated by default as identity PRIMARY KEY,
    item_name VARCHAR2(255) not null ,
    item_description VARCHAR2(1024),
    item_price DECIMAL not null ,
    CONSTRAINT item_price_check CHECK (item_price >= 0)
);

/*
Table represents the 'Allergen' entity.
Represents allergens that may be present in the items. Attributes include allergen ID, name, and description.
*/
CREATE TABLE Allergens (
    allergen_id INT generated by default as identity PRIMARY KEY,
    allergen_name VARCHAR2(255) not null ,
    allergen_description VARCHAR2(1000)
);

/*
Table represents the 'Ingredient' entity.
Represents ingredients used in the bakery items. Attributes include ingredient ID, name, description, and price.
*/
CREATE TABLE Ingredients (
    ingredient_id INT generated by default as identity PRIMARY KEY,
    ingredient_name VARCHAR2(255) not null,
    ingredient_description VARCHAR2(1000),
    ingredient_price DECIMAL not null ,
    CONSTRAINT ingredient_price_check CHECK (ingredient_price >= 0)
);

-- Employee, is sub type of Person, have a foreign key to Person and salary, position and bank
-- account number
CREATE TABLE Employee (
    person_id int PRIMARY KEY,
    salary DECIMAL not null ,
    CONSTRAINT salary_check CHECK (salary >= 0),
    position varchar(255) NOT NULL,
    bank_account_number varchar(255) NOT NULL,
    CONSTRAINT fk_employee_person_id
        FOREIGN KEY (person_id)
        REFERENCES Person(person_id)
        ON DELETE CASCADE
);

-- Courier, is sub type of Employee, have a foreign key to Employee, completed orders starts with 0,
-- contact phone number
CREATE TABLE Courier (
    person_id int PRIMARY KEY,
    completed_orders_amount int DEFAULT 0, -- todo: add trigger
    contact_phone_number varchar(255) NOT NULL,
    CONSTRAINT contact_phone_number_check CHECK (REGEXP_LIKE (contact_phone_number, '^\+42[01][0-9]{9}$')),
    CONSTRAINT fk_courier_person_id
        FOREIGN KEY (person_id)
        REFERENCES Employee(person_id)
        ON DELETE CASCADE
);

-- Address, id, have a foreign key to Person, street, city, building number
CREATE TABLE Address (
    address_id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    person_id int NOT NULL,
    street varchar(255) NOT NULL,
    city varchar(255) NOT NULL,
    building_number varchar(255) NOT NULL,
    CONSTRAINT fk_address_person_id
        FOREIGN KEY (person_id)
        REFERENCES Customers(person_id)
        ON DELETE CASCADE
);

-- Car, registration number, cost of maintenance have an optional foreign key to Courier
CREATE TABLE Car (
    registration_number varchar(255) PRIMARY KEY, -- todo : CHECK
    cost_of_maintenance DECIMAL not null ,
    CONSTRAINT cost_of_maintenance_check CHECK (cost_of_maintenance >= 0),
    courier_id INT UNIQUE, -- todo сделать зависимость что если курьер удаляется то машина становится свободной
    CONSTRAINT fk_car_courier_id
        FOREIGN KEY (courier_id)
        REFERENCES Courier(person_id)
        ON DELETE SET NULL
);

-- delivery ticket, ticket id, have a foreign key to Courier, have a foreign key to Address, have a
-- foreign key to Order, delivery date, time from, time to
CREATE TABLE DeliveryTicket (
    ticket_id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    courier_id int DEFAULT NULL,
    address_id int NOT NULL,
    order_id int NOT NULL,
    delivery_date DATE NOT NULL,
    -- CONSTRAINT delivery_date_check CHECK (delivery_date <= sysdate),-- todo:
    time_from VARCHAR2(50) NOT NULL, -- todo: CHECK
    time_to VARCHAR2(50) NOT NULL,
    FOREIGN KEY (courier_id) REFERENCES Courier(person_id) on delete set null,
    FOREIGN KEY (address_id) REFERENCES Address(address_id) on delete CASCADE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) on delete CASCADE  -- todo Законенктить к ордеру
);

-- WorkingShift, shift id, date, duration
CREATE TABLE WorkingShift (
    shift_id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    sift_date DATE NOT NULL,
    -- CONSTRAINT sift_date_check CHECK (sift_date <= sysdate), -- todo:
    duration VARCHAR2(50) NOT NULL -- todo: CHECK
);

/******************** ASSOCIATIVE TABLES ********************/

/*
Associative table represents the 'contain' relationship between 'Order' and 'Item' entities.
*/
CREATE TABLE Order_contains_Items (
    oci_order_id INT NOT NULL,
    oci_item_article_number INT NOT NULL,
    oci_items_count INT NOT NULL,
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (oci_order_id)
        REFERENCES Orders(order_id)
        ON DELETE CASCADE, -- Каскадное удаление для Orders
    CONSTRAINT fk_order_items_item
        FOREIGN KEY (oci_item_article_number)
        REFERENCES Items(item_article_number)
        ON DELETE CASCADE,
    CONSTRAINT pk_order_items PRIMARY KEY (oci_order_id, oci_item_article_number)
);

/*
Associative table represents the 'contain' relationship between 'Item' and 'Allergen' entities.
*/
CREATE TABLE Items_contains_Allergens (
    ica_article_number INT not null ,
    ica_allergen_id INT not null ,
    CONSTRAINT fk_item_allergen_article_number
        FOREIGN KEY (ica_article_number)
        REFERENCES Items(item_article_number)
        ON DELETE CASCADE,
    CONSTRAINT fk_item_allergen_allergen_id
        FOREIGN KEY (ica_allergen_id)
        REFERENCES Allergens(allergen_id)
        ON DELETE CASCADE,
    CONSTRAINT pk_item_allergen
        PRIMARY KEY (ica_article_number, ica_allergen_id)
);

/*
Associative table represents the 'consists of' relationship between 'Item' and 'Ingredient' entities.
*/
CREATE TABLE Items_consist_of_Ingredients (
    icoi_article_number INT NOT NULL,
    icoi_ingredient_id INT NOT NULL,
    icoi_ingredients_count INT NOT NULL,
    CONSTRAINT fk_item_ingredients_article_number
        FOREIGN KEY (icoi_article_number)
        REFERENCES Items(item_article_number)
        ON DELETE CASCADE,
    CONSTRAINT fk_item_ingredients_ingredient_id
        FOREIGN KEY (icoi_ingredient_id)
        REFERENCES Ingredients(ingredient_id)
        ON DELETE CASCADE,
    CONSTRAINT pk_item_ingredients
        PRIMARY KEY (icoi_article_number, icoi_ingredient_id)
);

-- Worker_Shift, have a foreign key to Employee, have a foreign key to WorkingShift
CREATE TABLE Worker_Shift (
    person_id int NOT NULL,
    shift_id int NOT NULL,
    FOREIGN KEY (person_id) REFERENCES Employee(person_id),
    CONSTRAINT fk_working_shift_id
        FOREIGN KEY (shift_id)
        REFERENCES WorkingShift(shift_id)
        ON DELETE CASCADE
);

/******************** TRIGGERS  ********************/

CREATE OR REPLACE TRIGGER order_date_before_insert_or_update
BEFORE INSERT OR UPDATE ON Orders
FOR EACH ROW
BEGIN
  IF :NEW.order_date > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20000, 'order_date cannot be in the future.');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER delivery_ticket_date_before_insert_or_update
BEFORE INSERT OR UPDATE ON DeliveryTicket
FOR EACH ROW
BEGIN
  IF :NEW.delivery_date > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20000, 'order_date cannot be in the future.');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER working_shift_date_before_insert_or_update
BEFORE INSERT OR UPDATE ON WorkingShift
FOR EACH ROW
BEGIN
  IF :NEW.sift_date > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20000, 'order_date cannot be in the future.');
  END IF;
END;
/

/******************** DATA INSERTION  ********************/

/***** ALLERGENS  *****/

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (1, 'Celery', 'Includes stalks, leaves, seeds, and the root called celeriac.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (2, 'Cereals containing gluten', 'Such as wheat, rye, barley, oats, spelled, kamut or their hybridised strains.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (3, 'Crustaceans', 'Includes crabs, lobster, prawns and shrimp paste.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (4, 'Eggs', 'Includes eggs from all poultry.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (5, 'Fish', 'Includes fish and fish products such as fish sauce.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES(6, 'Lupin', 'Includes lupin seeds and flour which can be found in types of bread, pastries and pasta.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (7, 'Milk', 'Includes cow’s milk and products made from milk, such as cheese, butter, and yogurt.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (8, 'Molluscs', 'Includes mussels, land snails, squid, and whelks.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (9, 'Mustard', 'Includes mustard seeds, powder, leaves, and paste.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (10, 'Tree nuts', 'Includes almonds, hazelnuts, walnuts, cashews, pecan nuts, Brazil nuts, pistachio nuts, macadamia or Queensland nuts.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (11, 'Peanuts', 'Includes peanuts and peanut-based products.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (12, 'Sesame seeds', 'Includes sesame seeds and products containing sesame.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (13, 'Soybeans', 'Includes soybeans and soybean products like tofu and soy sauce.');

INSERT INTO Allergens (allergen_id, allergen_name, allergen_description)
VALUES (14, 'Sulphur dioxide and sulphites', 'Commonly used as a preservative in dried fruit, wine, and other products.');

/***** INGREDIENT  *****/

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (1, 'Margarine', 'A butter substitute made from vegetable oils or animal fats.', 2.50);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (2, 'Milk', 'A nutrient-rich liquid food produced by the mammary glands of mammals.', 1.20);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (3, 'Butter', 'A dairy product made from churning cream or milk to separate the solid fats from the liquid.', 3.00);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (4, 'Flour', 'A powder obtained by grinding raw grains, roots, beans, nuts, or seeds.', 0.80);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (5, 'Baking powder', 'A dry chemical leavening agent used to increase the volume and lighten the texture of baked goods.', 1.00);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (6, 'Sugar', 'A sweet crystalline substance obtained from various plants, mostly sugarcane and sugar beet.', 1.10);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (7, 'Yeast', 'A microorganism used in baking and the fermentation of alcoholic beverages.', 1.30);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (8, 'Salt', 'A mineral composed primarily of sodium chloride, used as a seasoning and preservative.', 0.50);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (9, 'Eggs', 'An organic vessel containing the zygote in which an embryo develops.', 2.75);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (10, 'Water', 'A transparent, tasteless, odorless, and nearly colorless chemical substance, which is the main constituent of Earth’s hydrosphere.', 0.00);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (11, 'Vanilla extract', 'A solution containing the flavor compound vanillin as the primary ingredient.', 4.00);

INSERT INTO Ingredients (ingredient_id, ingredient_name, ingredient_description, ingredient_price)
VALUES (12, 'Cocoa powder', 'A powder made from roasted and ground cacao seeds, providing a chocolate flavor.', 3.50);

/***** ITEMS  *****/

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (1, 'French Baguette', 'A long, thin loaf of French bread known for its crisp crust and chewy texture.', 2.50);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (2, 'Croissant', 'A buttery, flaky, viennoiserie pastry of Austrian origin, named for its historical crescent shape.', 1.75);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (3, 'Chocolate Cake', 'A rich, moist chocolate cake with a layer of creamy chocolate frosting.', 4.00);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (4, 'Blueberry Muffin', 'A soft and fluffy muffin packed with fresh blueberries.', 1.50);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (5, 'Sourdough Bread', 'A type of bread made with naturally occurring lactic acid bacteria and yeast.', 3.50);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (6, 'Cinnamon Roll', 'A sweet roll served commonly in Northern Europe and North America, known for its spiral of cinnamon sugar.', 2.00);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (7, 'Apple Pie', 'A fruit pie in which the principal filling ingredient is apple, spiced with cinnamon, nutmeg, and sugar.', 3.25);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (8, 'Pumpkin Bread', 'A type of moist quick bread made with pumpkin puree and spices like nutmeg and cinnamon.', 2.75);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES (9, 'Cheesecake', 'A sweet dessert consisting of one or more layers, with the main and thickest layer containing a mixture of soft, fresh cheese, eggs, and sugar.', 4.50);

INSERT INTO Items (item_article_number, item_name, item_description, item_price)
VALUES(10, 'Rye Bread', 'Bread made with various percentages of flour from rye grain, known for its dark color and dense texture.', 3.00);

/***** Items consist of Ingredients  *****/

-- Ingredients for French Baguette
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (1, 4, 2); -- Flour for Baguette
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (1, 10, 1); -- Water for Baguette
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (1, 8, 1); -- Salt for Baguette

-- Ingredients for Croissant
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (2, 3, 1); -- Butter for Croissant
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (2, 4, 2); -- Flour for Croissant
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (2, 7, 1); -- Yeast for Croissant

-- Ingredients for Chocolate Cake
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (3, 4, 3); -- Flour for Chocolate Cake
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (3, 6, 2); -- Sugar for Chocolate Cake
INSERT INTO Items_consist_of_Ingredients (icoi_article_number, icoi_ingredient_id, icoi_ingredients_count)
VALUES (3, 12, 1); -- Cocoa Powder for Chocolate Cake

/***** Items contains Allergens  *****/
-- Allergens for French Baguette
INSERT INTO Items_contains_Allergens (ica_article_number, ica_allergen_id)
VALUES (1, 2); -- Gluten in Baguette

-- Allergens for Croissant
INSERT INTO Items_contains_Allergens (ica_article_number, ica_allergen_id)
VALUES (2, 2); -- Gluten in Croissant
INSERT INTO Items_contains_Allergens (ica_article_number, ica_allergen_id)
VALUES (2, 7); -- Milk in Croissant (because of the butter)

-- Allergens for Chocolate Cake
INSERT INTO Items_contains_Allergens (ica_article_number, ica_allergen_id)
VALUES (3, 2); -- Gluten in Chocolate Cake
INSERT INTO Items_contains_Allergens (ica_article_number, ica_allergen_id)
VALUES (3, 10); -- Tree nuts in Chocolate Cake
INSERT INTO Items_contains_Allergens (ica_article_number, ica_allergen_id)
VALUES (3, 13); -- Soybeans in Chocolate Cake

-- Вставка данных о человеке (клиенте и работниках)
INSERT INTO Person (name, surname) VALUES ('John', 'Doe'); -- ID=1 Клиент
INSERT INTO Person (name, surname) VALUES ('Jane', 'Smith'); -- ID=2 Работник (не курьер)
INSERT INTO Person (name, surname) VALUES ('Bob', 'Brown'); -- ID=3 Работник (курьер)

-- Вставка данных о клиенте
INSERT INTO Customers (person_id, order_amount) VALUES (1, 0);


INSERT INTO Address (person_id, street, city, building_number)
VALUES (1, 'Main Street', 'Springfield', '42A');


-- Вставка данных о работниках
INSERT INTO Employee (person_id, salary, position, bank_account_number)
VALUES (2, 50000, 'Baker', 'BA1234567890');
INSERT INTO Employee (person_id, salary, position, bank_account_number)
VALUES (3, 40000, 'Courier', 'CA0987654321');

-- Вставка данных о курьере
INSERT INTO Courier (person_id, completed_orders_amount, contact_phone_number)
VALUES (3, 0, '+420123456789');

INSERT INTO Car (registration_number, cost_of_maintenance, courier_id)
VALUES ('1ABC234', 500, 3);

-- Создание заказа
INSERT INTO Orders (order_customer_id, order_status, order_delivery_option, order_date, order_price, order_comment)
VALUES (1, 'NEW', 'COURIER_DELIVERY', TO_DATE('15-03-2024', 'DD-MM-YYYY'), 100, 'Please deliver ASAP.');

INSERT INTO DeliveryTicket (courier_id, address_id, order_id, delivery_date, time_from, time_to)
VALUES (3, 1, 1, TO_DATE('2024-03-16', 'YYYY-MM-DD'), '09:00', '12:00');

COMMIT;

-- SELECT * FROM Customers;
-- SELECT * FROM Orders;
-- SELECT * FROM Items;
-- SELECT * FROM Allergens;
-- SELECT * FROM Ingredients;
-- SELECT * FROM Order_contains_Items;
-- SELECT * FROM Items_consist_of_Ingredients;
-- SELECT * FROM Items_contains_Allergens;