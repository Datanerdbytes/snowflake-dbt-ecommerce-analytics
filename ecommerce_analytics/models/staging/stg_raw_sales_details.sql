with

source as (

    select * from {{ source('ecom_source', 'RAW_SALES_DETAILS') }}

),

renamed as (

    select
        ----------  ids
        sls_ord_num as order_number,
        sls_prd_key as product_key,
        sls_cust_id as customer_id,

        ---------- dates
        CASE
            WHEN sls_order_dt = 0
                 OR LENGTH(sls_order_dt::VARCHAR) < 8
            THEN NULL
            ELSE TRY_TO_DATE(sls_order_dt::VARCHAR, 'YYYYMMDD')
        END AS order_date,

         CASE
            WHEN sls_ship_dt = 0
                 OR LENGTH(sls_ship_dt::VARCHAR) < 8
            THEN NULL
            ELSE TRY_TO_DATE(sls_ship_dt::VARCHAR, 'YYYYMMDD')
        END AS shipped_date,

         CASE
            WHEN sls_due_dt = 0
                 OR LENGTH(sls_due_dt::VARCHAR) < 8
            THEN NULL
            ELSE TRY_TO_DATE(sls_due_dt::VARCHAR, 'YYYYMMDD')
        END AS due_date,

        ---------- numerics
        case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
              then sls_quantity * abs(sls_price)
             else sls_sales
        end as sales_amount,

        sls_quantity as quantity,
        
        case when sls_price is null or sls_price <= 0 then sls_sales / nullif(sls_quantity,0)
              else sls_price
        end as unit_price

    from source

)

select * from renamed
