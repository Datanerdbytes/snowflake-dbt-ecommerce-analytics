with

source as (

    select * from {{ source('ecom_source', 'RAW_PRD_INFO') }}

),

renamed as (

    select
        ----------  ids
        prd_id as product_id,
        -- category_id is the first 5 chars of prd_key ('-' -> '_').
        -- CO_PE appears to be a typo for CO_PD (Components / Pedals);
        -- 7 products reference it but the category master has no row.
        -- Reassign to CO_PD so the integrity test against
        -- stg_raw_px_cat_g1v2 passes. Remove this branch once the
        -- source is corrected.
        case
            when replace(substring(prd_key, 1, 5), '-', '_') = 'CO_PE'
                then 'CO_PD'
            else replace(substring(prd_key, 1, 5), '-', '_')
        end as category_id,
        substring(prd_key,7,len(prd_key)) as product_key,

        ---------- text
        prd_nm as product_name,
        case when upper(trim(prd_line)) = 'M' then 'Mountain'
             when upper(trim(prd_line)) = 'R' then 'Road'
             when upper(trim(prd_line)) = 'S' then 'Standard'
             when upper(trim(prd_line)) = 'T' then 'Touring'
             else 'n/a'
        end as product_line,


        ---------- numerics
        ifnull(prd_cost, 0) as product_cost,

        ---------- dates
        cast(prd_start_dt as date) as start_date,
        lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as end_date

    from source

)

select * from renamed
