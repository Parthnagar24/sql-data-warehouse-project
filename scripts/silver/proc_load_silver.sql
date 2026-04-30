/*
=============================================
STORED PROCEDURE : LOAD SILVER (BRONZE -> SILVER)
============================================
SCRIPT PURPOSE:
  this stored procedure performs the ETL process to populate the silver schema tables from bronze schema
ACTIONS PERFORMED:
  - truncate silver table
  - inserts transformed and cleaned data from bronze to silver tables
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT '------------------------------------------------';
        PRINT 'Starting Silver Layer Load';
        PRINT '------------------------------------------------';

        -- =============================================================================
        -- 1. Loading silver.crm_cust_info
        -- =============================================================================
        PRINT '>> Processing: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, 
            cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                 ELSE 'N/A'
            END,
            CASE WHEN UPPER(TRIM(cst_gnder)) = 'F' THEN 'Female'
                 WHEN UPPER(TRIM(cst_gnder)) = 'M' THEN 'Male'
                 ELSE 'N/A'
            END,
            cst_create_date
        FROM (
            SELECT *,
            ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
            FROM bronze.crm_cust_info
        ) t WHERE flag_last = 1;

        -- =============================================================================
        -- 2. Loading silver.crm_prd_info
        -- =============================================================================
        PRINT '>> Processing: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (
            prd_id, prd_key, categoryID, prd_nm, 
            prd_cost, prd_line, prd_start_dt, prd_end_dt 
        )
        SELECT
            prd_id,
            prd_key, 
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS categoryID,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE)
        FROM bronze.crm_prd_info;

        -- =============================================================================
        -- 3. Loading silver.crm_sales_details
        -- =============================================================================
        PRINT '>> Processing: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details(
            sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, 
            sls_ship_dt, sls_due_dt, sls_sales, sls_price, sls_quantity
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != ABS(sls_price) * sls_quantity 
                    THEN ABS(sls_price) * sls_quantity
                ELSE sls_sales
            END,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0
                    THEN (ABS(ISNULL(sls_sales, 0))) / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END,
            sls_quantity
        FROM bronze.crm_sales_details;

        -- =============================================================================
        -- 4. Loading ERP Tables
        -- =============================================================================
        PRINT '>> Processing: ERP Tables';

        -- erp_cust_az12
        TRUNCATE TABLE silver.erp_cust_az12;
        INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
        SELECT
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END,
            CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
            CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
                 WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
                 ELSE 'N/A'
            END
        FROM bronze.erp_cust_az12;

        -- erp_loc_a101
        TRUNCATE TABLE silver.erp_loc_a101;
        INSERT INTO silver.erp_loc_a101(cid, cntry)
        SELECT
            REPLACE(cid, '-', '_'),
            CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
                 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
                 ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        -- erp_px_cat_g1v2
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintaince
        FROM bronze.erp_px_cat_g1v2;

        PRINT '------------------------------------------------';
        PRINT 'Silver Layer Load Finished Successfully';
        PRINT '------------------------------------------------';

    END TRY
    BEGIN CATCH
        PRINT '################################################';
        PRINT 'ERROR OCCURRED DURING SILVER LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '################################################';
    END CATCH
END;
