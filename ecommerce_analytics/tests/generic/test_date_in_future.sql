{#
    Generic test: date_in_future

    Flags rows where the date column is strictly later than today.
    Use on date columns where future values are not valid
    (e.g. birth dates, hire dates, contract start dates).

    Use as a column-level test:
        columns:
          - name: bdate
            tests:
              - date_in_future

    The underlying model is inferred from the test context, so the macro
    works for any model without modification. NULL values pass — pair
    with `not_null` if missing dates are also unacceptable.
#}

{% test date_in_future(model, column_name) %}

with validation as (

    select
        {{ column_name }} as value_field
    from {{ model }}

)

select *
from validation
where value_field > current_date()

{% endtest %}
