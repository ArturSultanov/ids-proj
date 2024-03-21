/*
IDS - Databázové systémy.

Authors:
Kirill Shchetiniuk (xshche05),
Artur Sultanov (xsulta01).
*/


/******************** TABLES DROP ********************/
BEGIN
    -- WARNING: Deleting all existing project tables
    FOR existing_table IN (SELECT table_name FROM user_tables ) LOOP
        IF existing_table.TABLE_NAME in ('ADDRESS',
                                         'ALLERGENS',
                                         'CAR',
                                         'COURIER',
                                         'CUSTOMERS',
                                         'DELIVERY_TICKET',
                                         'EMPLOYEES',
                                         'INGREDIENTS',
                                         'ITEMS',
                                         'ITEMS_CONSIST_OF_INGREDIENTS',
                                         'ITEMS_CONTAINS_ALLERGENS',
                                         'ORDERS',
                                         'ORDER_CONTAINS_ITEMS',
                                         'PERSONS',
                                         'WORKER_SHIFT',
                                         'WORKING_SHIFT') THEN
            EXECUTE IMMEDIATE 'DROP TABLE ' || existing_table.table_name || ' CASCADE CONSTRAINTS PURGE';
        END IF;
    END LOOP;
END;
/

-- Date formatting
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';

/******************** TABLES ********************/

/*
General table for all people in the system. It is used as a parent table for other people like tables.
*/
CREATE TABLE Persons (
    person_id INT
        GENERATED BY DEFAULT AS IDENTITY -- The sequence for the generating PK
        PRIMARY KEY,
    name VARCHAR(255)
        NOT NULL,
    surname VARCHAR(255)
        NOT NULL
);

/*
Child table with a primary key to the parent table. Customers table, which contains information about customers.
It has a primary key person_id, which is derived from the Person table. First (by presentation) method of generalization
from ERD.
*/
CREATE TABLE Customers (
    /* ===== Attributes ===== */
    person_id INT
        PRIMARY KEY,
    order_amount INT
        DEFAULT 0,

    /* ===== Constraints ===== */
    CONSTRAINT fk_customer_person_id
        FOREIGN KEY (person_id)
        REFERENCES Persons (person_id)
        ON DELETE CASCADE -- Delete customer if person is deleted
);

/*
Child table with a primary key to the parent table. Employees table, which contains information about employees.
It has a primary key person_id, which is derived from the Person table. First (by presentation) method of generalization
from ERD.
*/
CREATE TABLE Employees (
    /* ===== Attributes ===== */
    person_id INT
        PRIMARY KEY,
    salary DECIMAL
        NOT NULL,
    position VARCHAR2(255)
        NOT NULL,
    bank_account_number VARCHAR2(255)
        NOT NULL,

    /* ===== Constraints ===== */
    CONSTRAINT salary_check
        CHECK (salary >= 0), -- Salary cannot be negative
    CONSTRAINT bank_account_number_check
        CHECK (REGEXP_LIKE(bank_account_number, '^[A-Z]{2}[0-9]{2}[A-Z0-9]{0,30}$')), -- IBAN number check
    CONSTRAINT fk_employee_person_id
        FOREIGN KEY (person_id)
        REFERENCES Persons (person_id)
        ON DELETE CASCADE -- Delete employee if person is deleted
);

/*
Child table with a primary key to the parent table. Courier table, which contains information about couriers.
It has a primary key person_id, which is derived from the Employee table. First (by presentation) method of generalization
from ERD.
*/
CREATE TABLE Courier (
    /* ===== Attributes ===== */
    person_id INT
        PRIMARY KEY,
    completed_orders_amount INT
        DEFAULT 0, -- todo: add trigger
    contact_phone_number VARCHAR2(255)
        NOT NULL,

    /* ===== Constraints ===== */
    CONSTRAINT contact_phone_number_check -- Check if phone number is in the correct format, slovakia and czech republic
        CHECK (REGEXP_LIKE(contact_phone_number, '^\+42[01][0-9]{9}$')),
    CONSTRAINT fk_courier_person_id
        FOREIGN KEY (person_id)
        REFERENCES Employees(person_id)
        ON DELETE CASCADE -- Delete courier if employee is deleted
);

/*
Table to store orders. It has a primary key order_id, which is generated by default as identity.
*/
CREATE TABLE Orders (
    /* ===== Attributes ===== */
    order_id INT
        GENERATED BY DEFAULT AS IDENTITY -- The sequence for the generating PK
        NOT NULL
        PRIMARY KEY,
    order_customer_id INT
        NOT NULL,
    order_status VARCHAR2(50) -- Statuses: NEW, IN_PROGRESS, COMPLETED, ARCHIVED
        DEFAULT 'NEW' -- Start status is NEW
        NOT NULL,
    order_delivery_option VARCHAR2(50) -- Options: COURIER_DELIVERY, SELF_PICKUP
        NOT NULL,
    order_date DATE
        NOT NULL,
    order_price DECIMAL
        DEFAULT 0
        NOT NULL,
    order_comment VARCHAR2(1024),

    /* ===== Constraints ===== */
    CONSTRAINT order_status_check -- Check if status is one of the predefined
        CHECK ( order_status in ('NEW', 'IN_PROGRESS', 'COMPLETED', 'ARCHIVED')),
    CONSTRAINT order_delivery_option_check -- Check if delivery option is one of the predefined
        CHECK ( order_delivery_option in ('COURIER_DELIVERY', 'SELF_PICKUP')),
    CONSTRAINT order_price_check -- Check if price is not negative
        CHECK (order_price >= 0),
    CONSTRAINT fk_order_customer_id
        FOREIGN KEY (order_customer_id)
        REFERENCES Customers(person_id)
        ON DELETE CASCADE -- Delete order if customer is deleted
);

/*
Table to store available items. It has a primary key item_article_number, which is generated by default as identity.
*/
CREATE TABLE Items (
    /* ===== Attributes ===== */
    item_article_number INT
        GENERATED BY DEFAULT AS IDENTITY -- The sequence for the generating PK
        PRIMARY KEY,
    item_name VARCHAR2(255)
        NOT NULL,
    item_price DECIMAL
        NOT NULL,
    item_description VARCHAR2(1024),

    /* ===== Constraints ===== */
    CONSTRAINT item_price_check
        CHECK (item_price >= 0) -- Price cannot be negative
);

/*
Table to store allergens. It has a primary key allergen_id, which is generated by default as identity.
*/
CREATE TABLE Allergens (
    /* ===== Attributes ===== */
    allergen_id INT
        GENERATED BY DEFAULT AS IDENTITY -- The sequence for the generating PK
        PRIMARY KEY,
    allergen_name VARCHAR2(255)
        NOT NULL,
    allergen_description VARCHAR2(1024)
);

/*
Table to store ingredients. It has a primary key ingredient_id, which is generated by default as identity.
*/
CREATE TABLE Ingredients (
    /* ===== Attributes ===== */
    ingredient_id INT
        GENERATED BY DEFAULT AS IDENTITY -- The sequence for the generating PK
        PRIMARY KEY,
    ingredient_name VARCHAR2(255)
        NOT NULL,
    ingredient_price DECIMAL
        NOT NULL,
    ingredient_description VARCHAR2(1024),

    /* ===== Constraints ===== */
    CONSTRAINT ingredient_price_check
        CHECK (ingredient_price >= 0) -- Price cannot be negative
);

/*
Table to store addresses. It has a primary key address_id, which is generated by default as identity. Every address is
linked to a single customer. FIXED FROM ERD.
*/
CREATE TABLE Address (
    /* ===== Attributes ===== */
    address_id INT
        GENERATED BY DEFAULT AS IDENTITY -- The sequence for the generating PK
        PRIMARY KEY,
    person_id INT
        NOT NULL,
    street VARCHAR2(255)
        NOT NULL,
    city VARCHAR2(255)
        NOT NULL,
    building_number VARCHAR2(255)
        NOT NULL,

    /* ===== Constraints ===== */
    CONSTRAINT fk_address_person_id
        FOREIGN KEY (person_id)
        REFERENCES Customers(person_id)
        ON DELETE CASCADE -- Delete address if customer is deleted
);

/*
Car table to store information about cars. It has a primary key registration_number, which is unique for each car.
Each car is linked to a single courier or no courier at all.
*/
CREATE TABLE Car (
    /* ===== Attributes ===== */
    registration_number VARCHAR2(255)
        PRIMARY KEY,
    cost_of_maintenance DECIMAL
        NOT NULL,
    courier_id INT
        UNIQUE, -- todo TRIGGER ONE COURIER - ONE CAR

    /* ===== Constraints ===== */
    CONSTRAINT cost_of_maintenance_check
        CHECK (cost_of_maintenance >= 0), -- Cost of maintenance cannot be negative
    CONSTRAINT fk_car_courier_id
        FOREIGN KEY (courier_id)
        REFERENCES Courier(person_id)
        ON DELETE SET NULL -- Free car for other couriers if courier is deleted
);

/*
Table to store delivery tickets. It has a primary key ticket_id, which is generated by default as identity.
Single delivery ticket is linked to a single courier, address, and order.
*/
CREATE TABLE Delivery_Ticket (
    /* ===== Attributes ===== */
    ticket_id INT
        GENERATED BY DEFAULT AS IDENTITY -- The sequence for the generating PK
        PRIMARY KEY,
    courier_id INT
        DEFAULT NULL,
    address_id INT
        NOT NULL,
    order_id INT
        NOT NULL,
    delivery_date DATE
        NOT NULL, -- TODO FIX/ADD CHECK
    time_from TIMESTAMP
        NOT NULL,
    time_to TIMESTAMP
        NOT NULL,

    /* ===== Constraints ===== */
    CONSTRAINT fk_courier_id_check
        FOREIGN KEY (courier_id)
        REFERENCES Courier(person_id)
        ON DELETE SET NULL, -- Update courier to NULL if courier is deleted
    CONSTRAINT fk_address_id_check
        FOREIGN KEY (address_id)
        REFERENCES Address(address_id)
        ON DELETE CASCADE, -- Delete delivery ticket if address is deleted
    CONSTRAINT fk_order_id_check
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
        ON DELETE CASCADE, -- Delete delivery ticket if order is deleted
    CONSTRAINT time_gap_check
        CHECK (time_from < time_to)  -- Time from should be less than time to
);

/*
Table to store working shifts. It has a primary key shift_id, which is generated by default as identity.
Has a start time and duration (in hours), maximum duration is 8 hours.
 */
CREATE TABLE Working_Shift (
    /* ===== Attributes ===== */
    shift_id INT
        GENERATED BY DEFAULT AS IDENTITY -- The sequence for the generating PK
        PRIMARY KEY,
    shift_start TIMESTAMP
        NOT NULL, -- todo: CHECK
    duration DECIMAL
        NOT NULL

    /* ===== Constraints ===== */
    CONSTRAINT duration_check
        CHECK (duration > 0 AND duration <= 8)
);

/******************** ASSOCIATIVE TABLES ********************/

/*
Associative table to store the relationship (contains) between orders and items.
It has a composite primary key (oci_order_id, oci_item_article_number).
*/
CREATE TABLE Order_contains_Items (
    /* ===== Linking Attributes ===== */
    oci_order_id INT
        NOT NULL,
    oci_item_article_number INT
        NOT NULL,
    oci_items_count INT
        NOT NULL,

    /* ===== Constraints ===== */
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (oci_order_id)
        REFERENCES Orders(order_id)
        ON DELETE CASCADE, -- Delete record if order is deleted
    CONSTRAINT fk_order_items_item
        FOREIGN KEY (oci_item_article_number)
        REFERENCES Items(item_article_number)
        ON DELETE CASCADE, -- Delete record if item is deleted
    CONSTRAINT pk_order_items
        PRIMARY KEY (oci_order_id, oci_item_article_number) -- Composite primary key
);

/*
Associative table to store the relationship (contains) between items and allergens.
*/
CREATE TABLE Items_contains_Allergens (
    /* ===== Linking Attributes ===== */
    ica_article_number INT
        NOT NULL,
    ica_allergen_id INT
        NOT NULL,

    /* ===== Constraints ===== */
    CONSTRAINT fk_item_allergen_article_number
        FOREIGN KEY (ica_article_number)
        REFERENCES Items(item_article_number)
        ON DELETE CASCADE, -- Delete record if item is deleted
    CONSTRAINT fk_item_allergen_allergen_id
        FOREIGN KEY (ica_allergen_id)
        REFERENCES Allergens(allergen_id)
        ON DELETE CASCADE, -- Delete record if allergen is deleted
    CONSTRAINT pk_item_allergen
        PRIMARY KEY (ica_article_number, ica_allergen_id) -- Composite primary key
);

/*
Associative table to store the relationship (consist of) between items and ingredients.
*/
CREATE TABLE Items_consist_of_Ingredients (
    /* ===== Linking Attributes ===== */
    icoi_article_number INT
        NOT NULL,
    icoi_ingredient_id INT
        NOT NULL,
    icoi_ingredients_count INT
        NOT NULL,

    /* ===== Constraints ===== */
    CONSTRAINT fk_item_ingredients_article_number
        FOREIGN KEY (icoi_article_number)
        REFERENCES Items(item_article_number)
        ON DELETE CASCADE, -- Delete record if item is deleted
    CONSTRAINT fk_item_ingredients_ingredient_id
        FOREIGN KEY (icoi_ingredient_id)
        REFERENCES Ingredients(ingredient_id)
        ON DELETE CASCADE, -- Delete record if ingredient is deleted
    CONSTRAINT pk_item_ingredients
        PRIMARY KEY (icoi_article_number, icoi_ingredient_id) -- Composite primary key
);

/*
Associative table to store the relationship (works in) between employees and working shifts.
*/
CREATE TABLE Worker_Shift (
    /* ===== Linking Attributes ===== */
    person_id INT
        NOT NULL,
    shift_id INT
        NOT NULL,

    /* ===== Constraints ===== */
    CONSTRAINT pk_person_shift_id
        FOREIGN KEY (person_id)
        REFERENCES Employees(person_id)
        ON DELETE CASCADE, -- Delete record if employee is deleted
    CONSTRAINT fk_working_shift_id
        FOREIGN KEY (shift_id)
        REFERENCES Working_Shift(shift_id)
        ON DELETE CASCADE, -- Delete record if working shift is deleted
    CONSTRAINT pk_person_shift
        PRIMARY KEY (person_id, shift_id) -- Composite primary key
);

/******************** TRIGGERS  ********************/

-- PART #4 - will be used for 'SQL skript pro vytvoření pokročilých objektů schématu databáze' task

-- CREATE OR REPLACE TRIGGER order_date_before_insert_or_update
-- BEFORE INSERT OR UPDATE ON Orders
-- FOR EACH ROW
-- BEGIN
--   IF :NEW.order_date > SYSDATE THEN
--     RAISE_APPLICATION_ERROR(-20000, 'order_date cannot be in the future.');
--   END IF;
-- END;
-- /

-- CREATE OR REPLACE TRIGGER delivery_ticket_date_before_insert_or_update
-- BEFORE INSERT OR UPDATE ON Delivery_Ticket
-- FOR EACH ROW
-- BEGIN
--   IF :NEW.delivery_date > SYSDATE THEN
--     RAISE_APPLICATION_ERROR(-20000, 'order_date cannot be in the future.');
--   END IF;
-- END;
-- /

-- CREATE OR REPLACE TRIGGER working_shift_date_before_insert_or_update
-- BEFORE INSERT OR UPDATE ON WorkingShift
-- FOR EACH ROW
-- BEGIN
--   IF :NEW.sift_date > SYSDATE THEN
--     RAISE_APPLICATION_ERROR(-20000, 'order_date cannot be in the future.');
--   END IF;
-- END;
-- /

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

/***** INGREDIENTS  *****/

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

/***** Persons  *****/

-- Inserting data about a person (client and employees)
INSERT INTO Persons (name, surname) VALUES ('Sheev', 'Palpatine');              -- ID=1 Client
INSERT INTO Persons (name, surname) VALUES ('Luke', 'Skywalker');               -- ID=2 Employee (not a courier)
INSERT INTO Persons (name, surname) VALUES ('Han', 'Solo');                     -- ID=3 Employee (courier)
INSERT INTO Persons (person_id, Name, Surname) VALUES (4, 'Darth', 'Vader');    -- ID=4 Client

/***** Customers  *****/

-- Inserting customer data
INSERT INTO Customers (person_id, order_amount) VALUES (1, 1);                  -- Sheev Palpatine
INSERT INTO Customers (person_id, order_amount) VALUES (4, 2);                  -- Darth Vader

/***** Persons  *****/
-- Inserting customer address
INSERT INTO Address (person_id, street, city, building_number)                  -- Sheev Palpatine
VALUES (1, 'Palace Street', 'Coruscant', '42A');
INSERT INTO Address (person_id, street, city, building_number)                  -- Darth Vader
VALUES (4, 'Control post', 'Death Star', '1C');

/***** Employees  *****/

-- Inserting Employees data
INSERT INTO Employees (person_id, salary, position, bank_account_number)
VALUES (2, 50000, 'Baker', 'GB29NWBK60161331926819');
INSERT INTO Employees (person_id, salary, position, bank_account_number)
VALUES (3, 40000, 'Courier', 'US00ABCD123456789012345678');

/***** Courier  *****/

-- Inserting courier data
INSERT INTO Courier (person_id, completed_orders_amount, contact_phone_number)
VALUES (3, 0, '+420123456789');

/***** Car  *****/

-- Inserting car data
INSERT INTO Car (registration_number, cost_of_maintenance, courier_id)
VALUES ('1ABC234', 500, 3);

/***** Working_Shift  *****/

INSERT INTO Working_Shift (shift_start, duration)
VALUES (TO_TIMESTAMP('2024-03-25 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 8); -- Morning shift for 8 hours
INSERT INTO Working_Shift (shift_start, duration)
VALUES (TO_TIMESTAMP('2024-03-25 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 8); -- Afternoon shift for 8 hours

/***** Worker_Shift  *****/

INSERT INTO Worker_Shift (person_id, shift_id)
VALUES (2, 1); -- Assigning Luke Skywalker to the morning shift
INSERT INTO Worker_Shift (person_id, shift_id)
VALUES (3, 2); -- Assigning Han Solo to the afternoon shift

/***** Orders  *****/

-- Inserting orders data
INSERT INTO Orders (order_customer_id, order_status, order_delivery_option, order_date, order_price, order_comment)
VALUES (1, 'NEW', 'COURIER_DELIVERY', TO_DATE('15-03-2024', 'DD-MM-YYYY'), 100, 'Please deliver ASAP.');
INSERT INTO Orders (order_customer_id, order_status, order_delivery_option, order_date, order_price, order_comment)
VALUES (4, 'NEW', 'SELF_PICKUP', TO_DATE('07-03-2024', 'DD-MM-YYYY'), 500, '');
INSERT INTO Orders (order_customer_id, order_status, order_delivery_option, order_date, order_price, order_comment)
VALUES (4, 'NEW', 'COURIER_DELIVERY', TO_DATE('25-12-2023', 'DD-MM-YYYY'), 200, 'Pack in a gift box');

/***** Order_contains_Items  *****/

-- Inserting items to an Order 1
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (1, 1, 2); -- Adding 2 French Baguettes to order ID 1
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (1, 3, 1); -- Adding 1 Chocolate Cake to order ID 1
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (1, 5, 1); -- Adding 1 Sourdough Bread to order ID 1

-- Adding items to an Order 2
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (2, 2, 3); -- Adding 3 Croissants to order ID 2
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (2, 4, 2); -- Adding 2 Blueberry Muffins to order ID 2
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (2, 7, 1); -- Adding 1 Apple Pie to order ID 2

-- Adding items to order ID 3
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (3, 6, 2); -- Adding 2 Cinnamon Rolls to order ID 3
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (3, 9, 1); -- Adding 1 Cheesecake to order ID 3
INSERT INTO Order_contains_Items (oci_order_id, oci_item_article_number, oci_items_count)
VALUES (3, 10, 3); -- Adding 3 Rye Breads to order ID 3


/***** Delivery_Ticket  *****/

-- Inserting delivery ticket data
INSERT INTO Delivery_Ticket (courier_id, address_id, order_id, delivery_date, time_from, time_to)
VALUES (3, 1, 1, TO_DATE('2024-03-16', 'YYYY-MM-DD'),
        TO_TIMESTAMP('2024-03-16:09:00:00', 'YYYY-MM-DD:HH24:MI:SS'),
        TO_TIMESTAMP('2024-03-16:12:00:00', 'YYYY-MM-DD:HH24:MI:SS'));
INSERT INTO Delivery_Ticket (courier_id, address_id, order_id, delivery_date, time_from, time_to)
VALUES (3, 2, 2, TO_DATE('2024-03-08', 'YYYY-MM-DD'),
        TO_TIMESTAMP('2024-03-08:09:00:00', 'YYYY-MM-DD:HH24:MI:SS'),
        TO_TIMESTAMP('2024-03-08:12:00:00', 'YYYY-MM-DD:HH24:MI:SS'));
INSERT INTO Delivery_Ticket (courier_id, address_id, order_id, delivery_date, time_from, time_to)
VALUES (3, 2, 3, TO_DATE('2024-03-16', 'YYYY-MM-DD'),
        TO_TIMESTAMP('2024-12-31:09:00:00', 'YYYY-MM-DD:HH24:MI:SS'),
        TO_TIMESTAMP('2024-12-31:12:00:00', 'YYYY-MM-DD:HH24:MI:SS'));

COMMIT;

-- PART #3 - will be used for 'SQL skript s dotazy SELECT' task

/***** Queries Utilizing JOINs  *****/

-- -- Find all orders along with customer names.
-- SELECT C.person_id, P.name, P.surname, O.order_id, O.order_status, O.order_price
-- FROM Customers C
-- JOIN Persons P ON C.person_id = P.person_id
-- JOIN Orders O ON C.person_id = O.order_customer_id;
--
-- -- Find delivery details for all orders.
-- SELECT O.order_id, O.order_status, DT.delivery_date, DT.time_from, DT.time_to
-- FROM Orders O
-- JOIN Delivery_Ticket DT ON O.order_id = DT.order_id;
--
-- /***** Query Utilizing JOIN among Three Tables *****/
--
-- -- Find items included in each order, along with the customer who placed the order.
-- SELECT O.order_id, I.item_name, OCI.oci_items_count, P.name, P.surname
-- FROM Order_contains_Items OCI
-- JOIN Items I ON OCI.oci_item_article_number = I.item_article_number
-- JOIN Orders O ON OCI.oci_order_id = O.order_id
-- JOIN Customers C ON O.order_customer_id = C.person_id
-- JOIN Persons P ON C.person_id = P.person_id;
--
-- /***** Queries with GROUP BY and Aggregate Function *****/
--
-- -- Calculate the total price of orders by their status.
-- SELECT O.order_status, SUM(O.order_price) AS total_price
-- FROM Orders O
-- GROUP BY O.order_status;
--
-- -- Count the number of orders per customer.
-- SELECT P.name, P.surname, COUNT(O.order_id) AS total_orders
-- FROM Customers C
-- JOIN Persons P ON C.person_id = P.person_id
-- JOIN Orders O ON C.person_id = O.order_customer_id
-- GROUP BY C.person_id, P.name, P.surname;
--
-- -- Count the number of delivery tickets per delivery address.
-- SELECT A.street || ', ' || A.city || ', ' || A.building_number AS full_address, COUNT(DT.ticket_id) AS delivery_ticket_count
-- FROM Address A
-- JOIN Delivery_Ticket DT ON A.address_id = DT.address_id
-- GROUP BY A.address_id, A.street, A.city, A.building_number
-- ORDER BY delivery_ticket_count DESC;
--
-- /***** Query Using EXISTS Predicate  *****/
--
-- -- Find customers who have placed at least 2 order.
-- SELECT P.name, P.surname
-- FROM Persons P
-- WHERE EXISTS (
--     SELECT 2
--     FROM Customers C
--     JOIN Orders O ON C.person_id = O.order_customer_id
--     WHERE C.person_id = P.person_id
-- );
--
-- /***** Query Using IN with a Nested SELECT *****/
--
-- -- Find items that have been included in any orders.
-- SELECT I.item_name
-- FROM Items I
-- WHERE I.item_article_number IN (
--     SELECT OCI.oci_item_article_number
--     FROM Order_contains_Items OCI
-- );
