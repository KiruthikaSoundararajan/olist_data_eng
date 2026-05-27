select 
    order_id ,
    order_status,
    order_purchase_timestamp as ts_purchase,
    order_approved_at as ts_approved,
    order_delivered_carrier_date as ts_dispatch,
    order_delivered_customer_date as ts_delivered,
    order_estimated_delivery_date as ts_est_delivery

from {{ref('stg_orders')}}



-- flagged as 
-- (
--     select * ,
      
--              ( approval_before_purchase_flag +
--                dispatch_before_approval_flag +
--                delivery_before_dispatch_flag +
--                delivery_before_purchase_flag ) as flag_count
--     from base
-- ),

-- validated as

-- (
--     select * ,
--     case 
--       when flag_count  = 1 then 'single_issue'
--       when flag_count  = 0 then 'no_issue'
--       else 'multiple_issues'
--     end as flag_severity,
--     case when 
--         flag_count > 0 then 'invalid'
--         else 'valid'
--         end as order_validity_status
--     from flagged
-- )

-- select * from validated