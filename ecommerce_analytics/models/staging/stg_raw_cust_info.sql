with 

source as (

    select * from {{ source('ecom_source', 'RAW_CUST_INFO') }}

),

renamed as (

    select
        ----------  ids
        cst_id as customer_id,
        row_number() over (partition by cst_key order by cst_create_date desc) as flag_last,
        cst_key as customer_key,

        ---------- text
        trim(cst_firstname) as first_name,
        trim(cst_lastname) as last_name,

        case when upper(trim(cst_marital_status)) = 'S' then 'Single'
             when upper(trim(cst_marital_status)) = 'M' then 'Married'
             else 'Unknown'
        end as marital_status,

        case when upper(trim(cst_gndr)) in ('F','FEMALE') then 'Female'
             when upper(trim(cst_gndr)) in ('M','MALE') then 'Male'
             else 'n/a'
        end as gender,

        ---------- dates
        cast(cst_create_date as date) as create_date

    from source
    where cst_id is not null

),

final as (
    select
        customer_id,
        customer_key,
        first_name,
        last_name,
        marital_status,
        gender,
        create_date
    from renamed
    where flag_last = 1
)

select * from final