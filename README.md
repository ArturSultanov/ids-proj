# IDS 

**IDS Project 2024**

**Project Number:** 6

**Project Name:** Bakery

## Assignment

Design a simple information system for a bakery that manages information about the types of bread offered, both from a production perspective (ingredients, costs, etc.) and sales (orders). The bakery provides delivery with its own cars, or customers can arrange their own pickup. The system must allow the bakery management to plan production based on orders and provide information for delivery, etc.

## Part 2 - SQL Script for Creating Database Schema Objects

An SQL script that creates basic database schema objects, such as tables including the definition of integrity constraints (especially primary and foreign keys), and populates the created tables with sample data. The database schema created must correspond to the data model from the previous part of the project and must meet the requirements stated in the following points (it is, of course, appropriate to correct errors and deficiencies that appeared in the ER diagram, or make partial changes leading to a higher quality solution).

### Requirements

- In the database schema tables, there must be at least one column with a special constraint on values, such as social security number or insurance number (SSN), personal/company identification number (ID), medical facility identification number, ISBN or ISSN, bank account number, etc. The database must only allow valid values in this column (implement using the CHECK integrity constraint).

- The database schema tables must have an appropriate realization of the generalization/specialization relationship for a purely relational database, meaning that the mentioned relationship and related entities of the data model must be suitably converted into a relational database schema. The chosen method of converting generalization/specialization into a relational database schema must be briefly explained (in an SQL code comment).

- The script must also include automatic generation of primary key values for some table from a sequence (for example, if the primary key value is undefined, i.e., NULL, when inserting records into the table).

### Implementation Notes

- Ensure to correct any errors and address deficiencies identified in the ER diagram to refine the database schema.
- Provide a brief explanation of the chosen method for realizing generalization/specialization relationships in your SQL script comments to clarify your design decisions.
- Implement integrity constraints, including CHECK constraints, to ensure data validity and consistency.
- Consider using sequences for automatic primary key generation to facilitate data insertion processes.
