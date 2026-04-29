/*
========================================================================
DDL SCRIPT : Create Bronze Tables
========================================================================
Script Purpose:
  This script creates table in the 'bronze' schema, dropping existing tables
  if they already exists.
Run this script to re-define the DDL structure of bronze tables

=========================================================================
*/

IF OBJECT_ID('bronze.erp_CUST_AZ12','U') IS NOT NULL
	DROP TABLE bronze.erp_CUST_AZ12;

CREATE TABLE bronze.erp_CUST_AZ12
(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50)

);
IF OBJECT_ID('bronze.erp_LOC_A101','U') IS NOT NULL
	DROP TABLE bronze.erp_LOC_A101;

CREATE TABLE bronze.erp_LOC_A101
(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50)
);
IF OBJECT_ID('bronze.erp_PX_CAT_G1V2','U') IS NOT NULL
	DROP TABLE bronze.erp_PX_CAT_G1V2;


CREATE TABLE bronze.erp_PX_CAT_G1V2
(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTAINCE NVARCHAR(50)
);
