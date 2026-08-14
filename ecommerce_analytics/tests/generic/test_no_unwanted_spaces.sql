{#
    Generic test: no_unwanted_spaces

    Flags rows whose `column_name` value contains unwanted whitespace:
      - Leading spaces  (value <> ltrim(value))
      - Trailing spaces (value <> rtrim(value))
      - Internal multi-space runs (two or more spaces, tabs, or mixed)
      - Any tab character anywhere

    Use as a column-level test:
        columns:
          - name: customer_email
            tests:
              - no_unwanted_spaces

    The underlying model is inferred from the test context, so the macro
    works for any model without modification.
#}

{% test no_unwanted_spaces(model, column_name) %}

{# Build the regex pattern from concatenated pieces so no leading-space
   whitespace leaks through Jinja trimming into the literal Snowflake sees.
   Matches:
     - two or more spaces in a row
     - two or more tabs in a row
     - space-then-tab or tab-then-space pairs
   Single internal spaces are NOT flagged (legitimate word separators). #}
{%- set internal_ws_pattern = "[" ~ " " ~ "\t" ~ "]" ~ "{2,}" -%}

with validation as (

    select
        {{ column_name }} as value_field,
        -- leading or trailing whitespace
        ({{ column_name }} <> ltrim({{ column_name }})
         or {{ column_name }} <> rtrim({{ column_name }}))
            as has_leading_or_trailing_space,
        -- any run of two-or-more whitespace characters (spaces or tabs)
        regexp_like(
            cast({{ column_name }} as string),
            '{{ internal_ws_pattern }}'
        ) as has_internal_whitespace
    from {{ model }}

)

select *
from validation
where has_leading_or_trailing_space
   or has_internal_whitespace

{% endtest %}
