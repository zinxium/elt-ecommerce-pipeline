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
        order_purchase_timestamp      as ordered_at,
        order_approved_at             as approved_at,
        order_delivered_carrier_date  as shipped_at,
        order_delivered_customer_date as delivered_at,
        order_estimated_delivery_date as estimated_delivery_at
    from source
    where order_id is not null
)

select * from cleaned