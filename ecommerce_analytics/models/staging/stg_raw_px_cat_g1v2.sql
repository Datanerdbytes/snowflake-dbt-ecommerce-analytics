with

source as (

    select * from {{ source('ecom_source', 'RAW_PX_CAT_G1V2') }}

),

renamed as (

    select
        ----------  ids
        id as category_id,

        ---------- text
        cat as category,
        subcat as subcategory,

        ---------- booleans
        cast(maintenance as boolean) as requires_maintenance

    from source

)

select * from renamed
