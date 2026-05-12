-- ============================================================
-- Schéma en étoile BigQuery — couche ANALYTICS
-- ============================================================

-- ── Dimension Clients ────────────────────────────────────────
CREATE OR REPLACE VIEW `e-commerce-496008.ecommerce_raw.dim_customers` AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix
FROM `e-commerce-496008.ecommerce_raw.raw_customers`;

-- ── Dimension Produits ───────────────────────────────────────
CREATE OR REPLACE VIEW `e-commerce-496008.ecommerce_raw.dim_products` AS
SELECT
    product_id,
    COALESCE(product_category_name, 'non_renseigné') AS product_category,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM `e-commerce-496008.ecommerce_raw.raw_products`;

-- ── Dimension Temps ──────────────────────────────────────────
CREATE OR REPLACE VIEW `e-commerce-496008.ecommerce_raw.dim_date` AS
SELECT DISTINCT
    DATE(TIMESTAMP(order_purchase_timestamp))                     AS date_day,
    
    EXTRACT(YEAR FROM TIMESTAMP(order_purchase_timestamp))        AS year,
    EXTRACT(MONTH FROM TIMESTAMP(order_purchase_timestamp))       AS month,
    EXTRACT(DAY FROM TIMESTAMP(order_purchase_timestamp))         AS day,
    EXTRACT(DAYOFWEEK FROM TIMESTAMP(order_purchase_timestamp))   AS day_of_week,
    EXTRACT(QUARTER FROM TIMESTAMP(order_purchase_timestamp))     AS quarter,
    
    FORMAT_DATE(
        '%Y-%m',
        DATE(TIMESTAMP(order_purchase_timestamp))
    ) AS year_month

FROM `e-commerce-496008.ecommerce_raw.raw_orders`
WHERE order_purchase_timestamp IS NOT NULL;


-- ── Fait Commandes ───────────────────────────────────────────
CREATE OR REPLACE VIEW `e-commerce-496008.ecommerce_raw.fct_orders` AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    DATE(o.order_purchase_timestamp)                        AS order_date,
    FORMAT_DATE('%Y-%m', DATE(o.order_purchase_timestamp))  AS order_month,

    DATE_DIFF(
        DATE(o.order_delivered_customer_date),
        DATE(o.order_purchase_timestamp),
        DAY
    ) AS delivery_days,

    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN TRUE ELSE FALSE
    END AS on_time_delivery,

    SUM(i.price)           AS total_revenue,
    SUM(i.freight_value)   AS total_freight,
    COUNT(i.order_item_id) AS total_items,
    AVG(r.review_score)    AS avg_review_score

FROM `e-commerce-496008.ecommerce_raw.raw_orders` o
LEFT JOIN `e-commerce-496008.ecommerce_raw.raw_order_items` i   ON o.order_id = i.order_id
LEFT JOIN `e-commerce-496008.ecommerce_raw.raw_order_reviews` r ON o.order_id = r.order_id
GROUP BY
    o.order_id, o.customer_id, o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date;