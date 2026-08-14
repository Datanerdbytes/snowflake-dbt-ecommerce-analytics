with

sales as (
    select * from {{ ref('stg_raw_sales_details') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),


joined as (
    select
        s.order_number,
        p.product_id,
        c.customer_key,
        s.order_date,
        s.shipped_date,
        s.due_date,
        s.sales_amount,
        s.quantity,
        s.unit_price
    from sales s
    left join products p
        on s.product_key = p.product_key
    left join customers c
        on s.customer_id = c.customer_id
)

select * from joined