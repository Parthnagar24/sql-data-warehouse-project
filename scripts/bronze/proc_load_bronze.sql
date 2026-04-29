/*
=====================================================================
Stored Procedure : load bronze layer (Source -> Bronze)
=====================================================================
Script Purpose:
  this stored procedure loads data into the bronze schema from external csv files
  it performs the following actions:
    - truncates the bronze table before loading data
    - uses the bulk insert command to load data from csv files to bronze tables

parameters:
none
this stored procedure does not accept any parameters or return any values

Usage Example:
  EXEC bronze.load_bronze;
==========================================================================
*/


EXECUTE bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
			PRINT '=================================';
			PRINT 'Loading Bronze layer';
			PRINT '=================================';

			PRINT '----------------------------------';
			PRINT 'loading crm Tables';
			PRINT '----------------------------------';

			SET @start_time =GETDATE();
			PRINT '>>Truncating the table :bronze.crm_cust_info'
			TRUNCATE TABLE bronze.crm_cust_info;

			PRINT ' >>Inserting data into table : bronze.crm_cust_info'
			BULK INSERT bronze.crm_cust_info
			FROM 'C:\Udemy-SSMS-SQL-Queries-2025\Udemy Material By Baara Khatib\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
			SET @end_time =GETDATE();
			PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'SECONDS';


			SET @start_time =GETDATE();
			PRINT '>>Truncating the table :bronze.crm_prd_info'
			TRUNCATE TABLE bronze.crm_prd_info;

			PRINT ' >>Inserting data into table : bronze.crm_prd_info'
			BULK INSERT bronze.crm_prd_info
			FROM 'C:\Udemy-SSMS-SQL-Queries-2025\Udemy Material By Baara Khatib\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
			SET @end_time =GETDATE();
			PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'SECONDS';

			SET @start_time =GETDATE();
			PRINT '>>Truncating the table :bronze.crm_sales_details'
			TRUNCATE TABLE bronze.crm_sales_details;

			PRINT ' >>Inserting data into table : bronze.crm_sales_details'
			BULK INSERT bronze.crm_sales_details
			FROM 'C:\Udemy-SSMS-SQL-Queries-2025\Udemy Material By Baara Khatib\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
			SET @end_time =GETDATE();
			PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'SECONDS';


			PRINT '----------------------------------';
			PRINT 'loading erp Tables';
			PRINT '----------------------------------';


			SET @start_time =GETDATE();
			PRINT '>>Truncating the table :bronze.erp_CUST_AZ12'
			TRUNCATE TABLE bronze.erp_CUST_AZ12;

			PRINT ' >>Inserting data into table : bronze.erp_CUST_AZ12'
			BULK INSERT bronze.erp_CUST_AZ12
			FROM 'C:\Udemy-SSMS-SQL-Queries-2025\Udemy Material By Baara Khatib\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
			SET @end_time =GETDATE();
			PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'SECONDS';



			SET @start_time =GETDATE();
			PRINT '>>Truncating the table :bronze.erp_LOC_A101'
			TRUNCATE TABLE bronze.erp_LOC_A101;

			PRINT ' >>Inserting data into table : bronze.erp_LOC_A101'
			BULK INSERT  bronze.erp_LOC_A101
			FROM 'C:\Udemy-SSMS-SQL-Queries-2025\Udemy Material By Baara Khatib\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
			SET @end_time =GETDATE();
			PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'SECONDS';


			SET @start_time =GETDATE();

			PRINT '>>Truncating the table :bronze.erp_PX_CAT_G1V2'
			TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

			PRINT ' >>Inserting data into table : bronze.erp_PX_CAT_G1V2'
			BULK INSERT  bronze.erp_PX_CAT_G1V2
			FROM 'C:\Udemy-SSMS-SQL-Queries-2025\Udemy Material By Baara Khatib\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);

			SET @end_time =GETDATE();
			PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'SECONDS';
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT ' ERROR OCCURED DURING BRONZE LAYER'
		PRINT ' ERROR MESSAGE'+ ERROR_MESSAGE();
		PRINT ' ERROR MESSAGE'+ CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
