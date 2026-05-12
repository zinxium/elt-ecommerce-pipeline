-- Staging products : correction des fautes de frappe du dataset Kaggle

with source as (
    select * from {{ source('raw', 'raw_products') }}
),

cleaned as (
    select
        product_id,

        -- Catégorie : on remplace les nulls par 'non_renseigne'
        coalesce(product_category_name, 'non_renseigne') as product_category,

        -- Correction des fautes de frappe Kaggle : lenght → length
        product_name_lenght        as product_name_length,
        product_description_lenght as product_description_length,

        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm

    from source
    where product_id is not null
)

select * from cleaned