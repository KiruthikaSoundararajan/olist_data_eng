select * 
from {{ref('int_orders_validated')}}
where order_validity_status = 'valid'