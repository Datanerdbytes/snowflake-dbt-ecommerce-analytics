with

source as (

    select * from {{ source('ecom_source', 'RAW_CUST_AZ12') }}

),

renamed as (

    select
        ----------  ids
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, len(cid))
            ELSE cid
        END AS customer_key,
        

        ---------- dates
        case when bdate > getdate() then null
            else bdate 
        end as birth_date,

        ---------- text
        case when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
             when upper(trim(gen)) in ('M', 'MALE') then 'Male'
             else 'n/a'
        end as gender

    from source

)

select * from renamed
