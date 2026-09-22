{#
    Generic test: end_date_greater_than_start_date

    Flags rows where the end-date column value is strictly less than the
    start-date column value. Used to enforce that date ranges are
    well-formed (start <= end).

    Args (passed as keyword arguments in YAML):
      column_name      — the start-date column (default: start_date)
      date_column_name — the end-date column   (default: end_date)

    Use as a column-level test:
        columns:
          - name: end_date
            tests:
              - end_date_greater_than_start_date:
                  date_column_name: prd_end_dt
                  column_name: prd_start_dt

    The underlying model is inferred from the test context, so the macro
    works for any model without modification. Either column being NULL
    causes the row to pass — pair with `not_null` on each column when
    missing dates are also unacceptable.
#}

{% test end_date_greater_than_start_date(model, column_name, date_column_name) %}

with validation as (

    select
        {{ column_name }}      as start_value,
        {{ date_column_name }} as end_value
    from {{ model }}

)

select *
from validation
where end_value < start_value

{% endtest %}
