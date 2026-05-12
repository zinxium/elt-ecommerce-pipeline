-- Staging orders : nettoyage de base des commandes brutes
-- source() dit à dbt d'aller chercher dans RAW.RAW_ORDERS

with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

cleaned as (
    select
        order_id,
        customer_id,
        order_status,

        -- Cast des timestamps texte en vrais types date
        try_cast(order_purchase_timestamp      as timestamp_ntz) as ordered_at,
        try_cast(order_approved_at             as timestamp_ntz) as approved_at,
        try_cast(order_delivered_carrier_date  as timestamp_ntz) as shipped_at,
        try_cast(order_delivered_customer_date as timestamp_ntz) as delivered_at,
        try_cast(order_estimated_delivery_date as timestamp_ntz) as estimated_delivery_at

    from source
    where order_id is not null  -- on filtre les lignes sans identifiant
)

select * from cleaned