with

source as (

    select * from {{ source('ecom_source', 'RAW_LOC_A101') }}

),

renamed as (

    select
        ----------  ids
        replace(cid, '-', '') as customer_key,

        ---------- text
        case when trim(cntry)  = 'DE' then  'Germany'
             when trim(cntry) in ('US', 'USA') then 'United States'
             when trim(cntry) = '' or cntry is null then 'n/a'
            else trim(cntry)
        end as country

    from source
)

select * from renamed
