with

customers as (
    select * from {{ ref('stg_raw_cust_info') }}
),

customers_birthday as (
    select * from {{ ref('stg_raw_cust_az12') }}
),

locations as (
    select * from  {{ ref('stg_raw_loc_a101') }}                       
),

joined as (
    select
        c.customer_id as customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        l.country,
        c.marital_status,
        case when c.gender != 'n/a' then c.gender -- stg_raw_cust_info is the master
            else coalesce(b.gender,'n/a')
        end as gender,
        b.birth_date,
        c.create_date
    from customers c
    left join customers_birthday b
        on c.customer_key = b.customer_key
    left join locations l
        on c.customer_key = l.customer_key
)

select * from joined