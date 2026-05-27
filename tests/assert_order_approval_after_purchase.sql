select *
from {{ref('stg_orders')}}
where order_approved_at is not null and 
    order_purchase_timestamp is not null and
    order_approved_at < order_purchase_timestamp