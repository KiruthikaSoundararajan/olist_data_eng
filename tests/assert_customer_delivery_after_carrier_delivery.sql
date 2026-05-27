select * 
from {{ref('stg_orders')}}
where order_delivered_carrier_date is not null and
      order_delivered_customer_date is not null and
      order_delivered_customer_date < order_delivered_carrier_date