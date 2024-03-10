# IDS 

**IDS Project 2024**

**Project Number:** 6

**Project Name:** Bakery

## Assignment

Design a simple information system for a bakery that manages information about the types of bread offered, both from a production perspective (ingredients, costs, etc.) and sales (orders). The bakery provides delivery with its own cars, or customers can arrange their own pickup. The system must allow the bakery management to plan production based on orders and provide information for delivery, etc.

## Database Project Documentation:

## Part 1: Data Model (ERD) and Use Case Model

### Data Model (ER Diagram)
The Data Model captures the structure or requirements for data in the database, expressed in UML class diagram notation (as in lectures) or as an ER diagram, for example, in the Crow's Foot notation. It represents the schema design based on the requirements.

### Use Case Model
Expressed as a UML Use Case Diagram, it represents the functional requirements of the application utilizing the designed data model. The data model must include at least one generalization/specialization relationship (i.e., an entity/class and some specialized entity/subclass connected by a generalization/specialization relationship; including the correct notation of the generalization/specialization relationship in the diagram).
The submission includes a document containing the above models along with a brief description of the data model. The description must clearly explain the significance of each entity and relationship set.

## Part 2: SQL Script for Creating Database Schema Objects

An SQL script that creates basic schema objects such as tables including the definition of integrity constraints (especially primary and foreign keys) and populates the created tables with sample data. The created schema must match the data model from the previous part of the project and must meet the requirements specified in the following points (it is, of course, appropriate to correct errors and deficiencies that appeared in the ER diagram, or to make partial changes leading to a more quality solution).
The database schema tables must include at least one column with a special value constraint, e.g., social security number or insurance number (SSN), personal/company identification number (ID), medical facility identification number (MFID), ISBN or ISSN, bank account number, etc. The database must allow only valid values in this column (implemented using the CHECK integrity constraint).
The database schema tables must have an appropriate realization of the generalization/specialization relationship designed for a purely relational database, i.e., the mentioned relationship and related entities of the data model must be appropriately converted into the relational database schema. The chosen method of converting generalization/specialization into the schema must be briefly explained (in the SQL code comment).
The script must also contain automatic generation of primary key values for some table from a sequence (e.g., if the primary key value of records being inserted into the given table will be undefined, i.e., NULL).

## Part 3: SQL Script with SELECT Queries

An SQL script that first creates basic schema objects and populates tables with sample data (as in point 2) and then performs several SELECT queries.
Specifically, this script must contain at least two queries using the join of two tables, one using the join of three tables, two queries with the GROUP BY clause and an aggregate function, one query containing the EXISTS predicate, and one query with the IN predicate with a nested select (not IN with a set of constant data), i.e., a total of at least 7 queries. Each query must be described understandably (in the SQL code comment) regarding what data the query is searching for (what is its function in the application).

## Part 4: SQL Script for Creating Advanced Database Schema Objects

An SQL script that first creates basic schema objects and populates tables with sample data (as in point 2), and then defines or creates advanced constraints or database objects according to the specifying requirements. This script will contain sample data manipulation commands and queries demonstrating the use of the above-mentioned constraints and objects (e.g., for demonstrating the use of indexes, it will first call the script EXPLAIN PLAN on a query without an index, then create an index, and finally call EXPLAIN PLAN on the query with the index; for the demonstration of a database trigger, data manipulation will be performed, which triggers the said trigger; etc.).
This SQL script must specifically contain all of the following:
- creation of at least two non-trivial database triggers including their demonstration,
- creation of at least two non-trivial stored procedures including their demonstration, in which there must (together) appear at least once a cursor, exception handling, and the use of a variable with a data type referring to a table row or column type (table_name.column_name%TYPE or table_name%ROWTYPE),
- explicit creation of at least one index so as to help optimize query processing, with the corresponding query affected by the index also provided, and the method of using the index in this query explained during the defense (this can be combined with EXPLAIN PLAN, see further),
- at least one use of EXPLAIN PLAN to output the execution plan of a database query with the join of at least two tables, an aggregate function, and the GROUP BY clause, with a comprehensible description and explanation of how, according to the output, the query execution will proceed, including clarification of the means used for its acceleration (e.g., use of an index, type of join, etc.), and further a method must be proposed on how specifically the query could be further accelerated (e.g., by introducing a new index), the proposed method performed (e.g., created index), EXPLAIN PLAN repeated, and its result compared with the result before the performance of the proposed acceleration method,
- definition of access rights to database objects for the second team member,
- creation of at least one materialized view belonging to the second team member and using tables defined by the first team member (access rights must already be defined), including SQL commands/queries showing how the materialized view works,
- creation of one complex SELECT query using the WITH clause and CASE operator. The note must state what data the query retrieves.
The project solution may optionally also include other elements not explicitly listed in the previous points or a greater number or complexity of elements listed. Such a solution can then be considered a superior solution and rewarded with additional points. An example of a superior solution can be a solution containing
- a client application implemented in any programming language, with the application work corresponding to the use cases stated in the solution of part 1 of the project – i.e., the application should not only display tables with data in a general way and offer the possibility of inserting new or modifying and deleting original data but should correspond to the work processes of users (for example, a librarian upon the arrival of a reader asks for the ID of the reader's card, the system lists the existing loans of the reader with marking any possible fines, the librarian has the opportunity to mark individual loans as just returned, possibly collect fines associated with loans, or add new loans of the given reader),
- SQL queries and commands showing transaction processing, including their description and explanation during the defense – e.g., a demonstration of the atomicity of transactions with concurrent access of multiple users/connections to the same data, a demonstration of locking, etc.
Students will need to explain individual parts of this script during the defense, especially the part with the EXPLAIN PLAN command. For this purpose, we recommend that students prepare (optionally) short text document notes for the defense, which can be part of the submission.
Tip: For debugging PL/SQL code in stored procedures or database triggers, you can use the procedure DBMS_OUTPUT.put_line(...) to output to the client terminal.

