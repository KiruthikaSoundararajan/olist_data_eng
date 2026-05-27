select 
    order_id,
    customer_id,

    lower(trim(order_status)) as order_status,

    to_timestamp(order_purchase_timestamp,'DD_MM_YYYY HH24-MI-SS') as order_purchase_timestamp,
    to_timestamp(order_approved_at ,'DD_MM_YYYY HH24-MI-SS') as order_approved_at,
    to_timestamp(order_delivered_carrier_date,'DD_MM_YYYY HH24-MI-SS') as order_delivered_carrier_date,
    to_timestamp(order_delivered_customer_date,'DD_MM_YYYY HH24-MI-SS') as order_delivered_customer_date,
    to_timestamp(order_estimated_delivery_date,'DD_MM_YYYY HH24-MI-SS') as order_estimated_delivery_date


from {{source('raw','orders')}}