with orders as (
    select * from {{ ref('stg_orders') }}
),

items as (
    select * from {{ source('raw', 'raw_order_items') }}
),

payments as (
    select * from {{ source('raw', 'raw_order_payments') }}
),

reviews as (
    select * from {{ source('raw', 'raw_order_reviews') }}
),

-- Agrégation des items par commande
items_agg as (
    select
        order_id,
        sum(price)          as total_revenue,
        sum(freight_value)  as total_freight,
        count(order_item_id) as total_items
    from items
    group by order_id
),

-- Agrégation des paiements par commande
payments_agg as (
    select
        order_id,
        sum(payment_value)  as total_payment,
        count(*)            as payment_count
    from payments
    group by order_id
),

-- Agrégation des avis par commande
reviews_agg as (
    select
        order_id,
        avg(review_score)   as avg_review_score
    from reviews
    group by order_id
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        date(o.ordered_at)                    as order_date,
        to_char(o.ordered_at, 'YYYY-MM')      as order_month,

        -- Délai de livraison en jours
        datediff('day', o.ordered_at, o.delivered_at) as delivery_days,

        -- Livré dans les délais ?
        case
            when o.delivered_at <= o.estimated_delivery_at
            then true else false
        end as on_time_delivery,

        -- Métriques financières
        coalesce(i.total_revenue, 0)   as total_revenue,
        coalesce(i.total_freight, 0)   as total_freight,
        coalesce(i.total_items, 0)     as total_items,
        coalesce(p.total_payment, 0)   as total_payment,
        coalesce(p.payment_count, 0)   as payment_count,

        -- Score avis
        r.avg_review_score

    from orders o
    left join items_agg    i on o.order_id = i.order_id
    left join payments_agg p on o.order_id = p.order_id
    left join reviews_agg  r on o.order_id = r.order_id
)

select * from final