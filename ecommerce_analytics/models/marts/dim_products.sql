with

products as (
    select * from {{ ref('stg_raw_prd_info') }}
),

categories as (
    select * from {{ ref('stg_raw_px_cat_g1v2') }}
),

joined as (
    select
        p.product_id,
        p.product_key,
        p.product_name,
        p.category_id,
        pc.category,
        pc.subcategory,
        pc.requires_maintenance as maintenance,
        p.product_cost,
        p.product_line,
        p.start_date
    from products p
    left join categories pc
    on p.category_id = pc.category_id
    where end_date is null -- filter out historical data
)

select * from joined
