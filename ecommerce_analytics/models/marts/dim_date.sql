with date_spine as (

    {{ dbt_utils.date_spine("day", "cast('2019-01-01' as date)", "cast('2024-12-31' as date)") }}

),

final as (

    select
        cast(date_day as date) as date_day,
        extract(year from date_day) as year_number,
        extract(quarter from date_day) as quarter_number,
        extract(month from date_day) as month_number,
        extract(week from date_day) as week_number,
        extract(day from date_day) as day_of_month,
        -- Snowflake's extract(dayofweek) returns 0-6 (Sun=0). Shift to 1-7 with 1=Monday for analyst-friendly convention.
        case when extract(dayofweek from date_day) = 0 then 7
             else extract(dayofweek from date_day)
        end as day_of_week_number,
        to_char(date_day, 'YYYY-MM') as year_month,
        to_char(date_day, 'YYYY-Q') as year_quarter,
        trim(to_char(date_day, 'Month')) as month_name,
        trim(to_char(date_day, 'Day')) as day_name
    from date_spine

)

select * from final
