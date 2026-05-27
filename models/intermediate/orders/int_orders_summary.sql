with base as
(
    select 
    order_id,
   (delivery_before_purchase+
   approval_before_purchase+
   dispatch_before_approval+
   delivery_before_dispatch)  as seq_violation_count,

   (missing_ts_purchase + 
   missing_ts_approved+
   missing_ts_dispatch+
   missing_ts_delivered) as missing_ts_count,
   
   (approved_status_without_ts + 
   dispatched_status_without_ts + 
   delivered_status_without_ts ) 
   as ts_lag_count,

   (approved_ts_without_status + 
   dispatch_ts_without_status + 
   delivered_ts_without_status) 
   as status_lag_count,

   nullif (concat_ws(',',
     case when order_status = 'unavailable' and missing_ts_purchase = 0 then 'purchased' else null end,
     case when order_status = 'unavailable' and missing_ts_approved = 0 then 'approved' else null end,
     case when order_status = 'unavailable' and missing_ts_dispatch = 0 then 'dispatched' else null end,
     case when order_status = 'unavailable' and missing_ts_delivered = 0 then 'delivered' else null end
   ),'') as unavailable_orders_anomaly,

   {{missing_stage_count('order_stage', 'fulfilled_stages', '1')}} as st_created_miss_stg_cnt,
   {{missing_stage_count('order_stage', 'fulfilled_stages', '2')}} as st_approved_miss_stg_cnt,
   {{missing_stage_count('order_stage', 'fulfilled_stages', '3')}} as st_invoiced_miss_stg_cnt,
   {{missing_stage_count('order_stage', 'fulfilled_stages', '4')}} as st_processing_miss_stg_cnt,
   {{missing_stage_count('order_stage', 'fulfilled_stages', '5')}} as st_dispatched_miss_stg_cnt,
   {{missing_stage_count('order_stage', 'fulfilled_stages', '6')}} as st_delivered_miss_stg_cnt,

 
   {{out_of_order_stage_count('order_stage', 'fulfilled_stages', '1')}} as st_created_oo_order_stg_cnt,
   {{out_of_order_stage_count('order_stage', 'fulfilled_stages', '2')}} as st_approved_oo_order_stg_cnt,
   {{out_of_order_stage_count('order_stage', 'fulfilled_stages', '3')}} as st_invoiced_oo_order_stg_cnt,
   {{out_of_order_stage_count('order_stage', 'fulfilled_stages', '4')}} as st_processing_oo_order_stg_cnt,
   {{out_of_order_stage_count('order_stage', 'fulfilled_stages', '5')}} as st_dispatched_oo_order_stg_cnt,
   {{out_of_order_stage_count('order_stage', 'fulfilled_stages', '6')}} as st_delivered_oo_order_stg_cnt

   from {{ref('int_orders_flagged')}}
   
),

summary_table as
(
   select *,

   case 
    when seq_violation_count = 0 then 'no_violation'
    when seq_violation_count = 1 then 'single_violation'
    when seq_violation_count > 1 then 'multiple_violations'
   end as seq_violation_severity,


   case
    when seq_violation_count > 0 then 'invalid'
    else 'valid'
   end as order_validity_status
   
   from base
)

select * from summary_table