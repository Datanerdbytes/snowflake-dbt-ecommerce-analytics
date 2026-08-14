with

sales as (
    select * from {{ ref('fact_sales') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

joined as (
    select
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,
        c.gender,
        c.birth_date,
        s.order_number,
        s.sales_amount,
        s.quantity,
        s.order_date
    from customers c
    left join sales s
        on c.customer_key = s.customer_key
),

aggregated as (
    select
        customer_key,
        customer_id,
        first_name,
        last_name,
        country,
        gender,
        birth_date,
        count(distinct order_number) as total_orders,
        count(order_number) as total_order_lines,
        sum(quantity) as total_units_purchased,
        sum(sales_amount) as lifetime_sales,
        avg(sales_amount) as avg_line_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        -- recency: days since most recent order, computed against current timestamp
        datediff('day', max(order_date), current_date) as days_since_last_order
    from joined
    group by 1, 2, 3, 4, 5, 6, 7
)

select * from aggregated
