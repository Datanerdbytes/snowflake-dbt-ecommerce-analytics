with

sales as (
    select * from {{ ref('fact_sales') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

joined as (
    select
        p.product_id,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.product_line,
        p.maintenance,
        p.product_cost,
        s.order_number,
        s.sales_amount,
        s.quantity,
        s.unit_price,
        s.order_date
    from products p
    left join sales s
        on p.product_id = s.product_id
),

aggregated as (
    select
        product_id,
        product_key,
        product_name,
        category,
        subcategory,
        product_line,
        maintenance,
        product_cost,
        count(distinct order_number) as total_orders,
        sum(quantity) as total_units_sold,
        sum(sales_amount) as total_revenue,
        avg(sales_amount) as avg_line_revenue,
        min(order_date) as first_sale_date,
        max(order_date) as last_sale_date,
        -- profit proxy: revenue - (product_cost * units_sold)
        sum(sales_amount) - (coalesce(product_cost, 0) * coalesce(sum(quantity), 0)) as total_profit
    from joined
    group by 1, 2, 3, 4, 5, 6, 7, 8
)

select * from aggregated
