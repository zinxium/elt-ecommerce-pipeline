with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

-- Statistiques par client
customer_stats as (
    select
        customer_id,
        count(order_id)        as total_orders,
        sum(total_revenue)     as lifetime_value,
        avg(avg_review_score)  as avg_satisfaction,
        min(order_date)        as first_order_date,
        max(order_date)        as last_order_date
    from orders
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        c.zip_code,

        -- Enrichissement avec stats commandes
        coalesce(s.total_orders, 0)    as total_orders,
        coalesce(s.lifetime_value, 0)  as lifetime_value,
        s.avg_satisfaction,
        s.first_order_date,
        s.last_order_date

    from customers c
    left join customer_stats s on c.customer_id = s.customer_id
)

select * from final