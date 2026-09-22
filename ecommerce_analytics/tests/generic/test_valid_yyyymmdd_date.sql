{#
    Generic test: valid_yyyymmdd_date

    Flags rows where the source date column — expected to be an integer
    in YYYYMMDD form — fails either of two checks:

      1. The numeric value is less than or equal to 0
         (catches 0, negatives, and any zero-padded junk rows).
      2. The string form is not exactly 8 characters long
         (catches truncation, short padded values, and malformed dates).

    Mirrors the SQL:
        where sls_order_dt <= 0 or len(sls_order_dt) != 8

    Use as a column-level test on raw date-as-int source columns:
        columns:
          - name: SLS_ORDER_DT
            tests:
              - valid_yyyymmdd_date

    The underlying model is inferred from the test context, so the macro
    works for any model without modification. NULL values pass — pair
    with `not_null` if missing dates are also unacceptable.
#}

{% test valid_yyyymmdd_date(model, column_name) %}

with validation as (

    select
        {{ column_name }} as value_field,
        -- (a) numeric value must be > 0
        ({{ column_name }} <= 0) as is_non_positive,
        -- (b) string length must be exactly 8
        (length(cast({{ column_name }} as varchar)) <> 8)
            as has_wrong_length
    from {{ model }}

)

select *
from validation
where is_non_positive
   or has_wrong_length

{% endtest %}
