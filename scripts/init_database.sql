/*
CREATE DATABASE AND SCHEMA
----------------------------
Script purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up 3 schemas
    within the database : 'bronze', 'silver', 'gold'.

Warnings: 
    Running this script will drop the entire DataWarehouse database if it exists.
    All the database will be permanently deleted.Proceed with caution
    ensure you have backups before running  this scripts.
*/

--Drop and recreate the 'Database- DataWarehouse'
IF EXISTS (SELECT 1 FROM sys.databases WHERE  name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO


--Create a Database

CREATE DATABASE DataWarehouse;
USE DataWarehouse;


--Create Schema

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
