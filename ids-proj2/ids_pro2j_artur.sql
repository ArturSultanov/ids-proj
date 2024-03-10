/*
IDS - Databázové systémy.
Projekt 2. část - SQL skript pro vytvoření objektů schématu databáze.

Authors:
Kirill Shchetiniuk (xshche05),
Artur Sultanov (xsulta01).
*/

-- DROP TABLES:
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Customers CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Orders CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Items CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Allergens CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Ingredients CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Order_contains_Items CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Items_consist_of_Ingredients CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Items_contains_Allergens CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 AND SQLCODE !=  -1418 THEN
            RAISE;
        END IF;
END;
/

-- Date formatting
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';


/******************** TABLES ********************/

-- Stub table of Customer
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY NOT NULL
);

/*
Table represents the 'Order' entity.
Holds details about customer orders, including a unique order ID,
status, delivery option, date of order, price, and comment.
'Orders' contain 'Items'. For that reason the Item_contains_Allergen associative table is implemented.
*/
CREATE TABLE Orders (
    order_id INT NOT NULL PRIMARY KEY,
    order_customer_id INT NOT NULL,
    order_status VARCHAR2(50),
    order_delivery_option VARCHAR2(50),
    order_date DATE,
    order_price DECIMAL(10, 2),
    order_comment VARCHAR2(255),
    FOREIGN KEY (order_customer_id) REFERENCES Customers(customer_id)
);

/*
Table represents the 'Item' entity.
Represents the bakery items for sale, with attributes such as article number, name, description, and price.
'Items' can contain 'Allergens'. For that reason the Items_contains_Allergens associative table is implemented.
'Items' consist of 'Ingredients'. For that reason the Items_consist_of_Ingredients associative table is implemented.
*/
CREATE TABLE Items (
    item_article_number INT NOT NULL PRIMARY KEY,
    item_name VARCHAR2(255),
    item_description VARCHAR2(1000),
    item_price DECIMAL(10, 2)
);

/*
Table represents the 'Allergen' entity.
Represents allergens that may be present in the items. Attributes include allergen ID, name, and description.
*/
CREATE TABLE Allergens (
    allergen_id INT NOT NULL PRIMARY KEY,
    allergen_name VARCHAR2(255),
    allergen_description VARCHAR2(1000)
);

/*
Table represents the 'Ingredient' entity.
Represents ingredients used in the bakery items. Attributes include ingredient ID, name, description, and price.
*/
CREATE TABLE Ingredients (
    ingredient_id INT NOT NULL PRIMARY KEY,
    ingredient_name VARCHAR2(255),
    ingredient_description VARCHAR2(1000),
    ingredient_price DECIMAL(10, 2)
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
        REFERENCES Items(item_article_number),
    CONSTRAINT pk_order_items PRIMARY KEY (oci_order_id, oci_item_article_number)
);

/*
Associative table represents the 'contain' relationship between 'Item' and 'Allergen' entities.
*/
CREATE TABLE Items_contains_Allergens (
    ica_article_number INT,
    ica_allergen_id INT,
    CONSTRAINT fk_item_allergen_article_number
        FOREIGN KEY (ica_article_number)
        REFERENCES Items(item_article_number)
        ON DELETE CASCADE,
    CONSTRAINT fk_item_allergen_allergen_id
        FOREIGN KEY (ica_allergen_id)
        REFERENCES Allergens(allergen_id),
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
        REFERENCES Items(item_article_number),
    CONSTRAINT fk_item_ingredients_ingredient_id
        FOREIGN KEY (icoi_ingredient_id)
        REFERENCES Ingredients(ingredient_id),
    CONSTRAINT pk_item_ingredients
        PRIMARY KEY (icoi_article_number, icoi_ingredient_id)
);


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

COMMIT;

SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM Items;
SELECT * FROM Allergens;
SELECT * FROM Ingredients;
SELECT * FROM Order_contains_Items;
SELECT * FROM Items_consist_of_Ingredients;
SELECT * FROM Items_contains_Allergens;
