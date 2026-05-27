select * 
from {{ref('stg_orders')}}
where order_approved_at is not null and
      order_delivered_carrier_date is not null and
      order_delivered_carrier_date < order_approved_at