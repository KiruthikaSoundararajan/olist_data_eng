select
   count(*) as total_rows,
   count(distinct customer_id) as unique_customer_ids
from {{source('raw','orders')}}
having count(*) != count(distinct customer_id)
