{#
    Generic test: non_negative

    Flags rows whose `column_name` value is less than zero.
    Use on numeric columns where negative values are not valid
    (e.g. costs, prices, quantities, counts, ages).

    Use as a column-level test:
        columns:
          - name: product_cost
            tests:
              - non_negative

    The underlying model is inferred from the test context, so the macro
    works for any model without modification. NULL values are NOT flagged —
    pair with `not_null` when missing values are also unacceptable.
#}

{% test non_negative(model, column_name) %}

with validation as (

    select
        {{ column_name }} as value_field
    from {{ model }}

)

select *
from validation
where value_field < 0

{% endtest %}
