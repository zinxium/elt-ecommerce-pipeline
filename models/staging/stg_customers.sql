-- Staging customers : nettoyage de base des clients

with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

cleaned as (
    select
        customer_id,
        customer_unique_id,

        -- Homogénéisation : ville en majuscules
        upper(customer_city)             as customer_city,
        upper(customer_state)            as customer_state,
        customer_zip_code_prefix         as zip_code

    from source
    where customer_id is not null
)

select * from cleaned