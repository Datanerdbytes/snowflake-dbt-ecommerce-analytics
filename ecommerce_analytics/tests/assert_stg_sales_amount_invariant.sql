-- Singular test: assert_stg_sales_amount_invariant
--
-- For every row in stg_raw_sales_details, sales_amount must equal
-- quantity * abs(unit_price). This is the invariant the staging model
-- guarantees after cleaning: it recomputes sales_amount from
-- quantity * abs(price) whenever the raw sls_sales was null, non-positive,
-- or inconsistent, and it falls back unit_price to sls_sales / quantity
-- whenever the raw sls_price was null or non-positive.
--
-- If a row's sales_amount and quantity * abs(unit_price) diverge by more
-- than 0.01, the row is returned here and the test fails.
--
-- Tolerance covers cent-level float rounding; tighten it if your
-- warehouse returns exact numerics.

select
    order_number,
    sales_amount,
    quantity,
    unit_price,
    quantity * abs(unit_price) as expected_sales_amount,
    abs(sales_amount - quantity * abs(unit_price)) as amount_diff
from {{ ref('stg_raw_sales_details') }}
where abs(sales_amount - quantity * abs(unit_price)) > 0.01