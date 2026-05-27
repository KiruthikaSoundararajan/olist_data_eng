with base as
(   
   select
   order_id,
   order_status,
   
   
   {{missing_value_check('ts_purchase')}} as missing_ts_purchase,
   {{missing_value_check('ts_approved')}} as missing_ts_approved,
   {{missing_value_check('ts_dispatch')}} as missing_ts_dispatch,
   {{missing_value_check('ts_delivered')}} as missing_ts_delivered,
   {{missing_value_check('ts_est_delivery')}}  as missing_ts_est_delivery,

   case 
        when order_status = 'created' then 1
        when order_status = 'approved' then 2
        when order_status = 'invoiced' then 3
        when order_status = 'processing' then 4
        when order_status = 'shipped' then 5
        when order_status = 'delivered' then 6
        else 0
   end as order_stage,

   ({{filled_value_check('ts_purchase')}}::text || {{filled_value_check('ts_approved')}}::text ||
   {{filled_value_check('ts_dispatch')}}::text || {{filled_value_check('ts_delivered')}}::text)::bit(4) 
   as fulfilled_stages,
   
   {{stage_sequence_violation('ts_est_delivery','ts_purchase')}}
   as est_delivery_before_purchase,

   {{stage_sequence_violation('ts_delivered','ts_purchase')}}
   as delivery_before_purchase,

   {{stage_sequence_violation('ts_approved','ts_purchase')}}
   as approval_before_purchase,
   
   {{stage_sequence_violation('ts_dispatch','ts_approved')}}
   as dispatch_before_approval,

   {{stage_sequence_violation('ts_delivered','ts_dispatch')}}
   as delivery_before_dispatch


   from {{ref('int_orders_lifecycle')}}
),


flagged_table as 
(
   select *,
   --status_updated_without_ts 
   -- rows that have the status updated but the timestamp is not updated
   {{status_without_ts('order_stage','2','missing_ts_approved')}} as approved_status_without_ts, 
   {{status_without_ts('order_stage','5','missing_ts_dispatch')}} as dispatched_status_without_ts, 
   {{status_without_ts('order_stage','6','missing_ts_delivered')}} as delivered_status_without_ts, 
   
   -- rows that have the fulfilled timestamp but the status is not updated
   {{ts_without_status('order_stage','2','missing_ts_approved')}} as approved_ts_without_status, 
   {{ts_without_status('order_stage','5','missing_ts_dispatch')}} as dispatch_ts_without_status,
   {{ts_without_status('order_stage','6','missing_ts_delivered')}} as delivered_ts_without_status,
   
      
   case when order_status = 'unavailable' and missing_ts_purchase = 0 then 1 else 0 end as purchased_unavailable_orders,
   case when order_status = 'unavailable' and missing_ts_approved = 0 then 1 else 0 end as approved_unavailable_orders,
   case when order_status = 'unavailable' and missing_ts_dispatch = 0 then 1 else 0 end as dispatched_unavailable_orders,
   case when order_status = 'unavailable' and missing_ts_delivered = 0 then 1 else 0 end as delivered_unavailable_orders,
   
    --stages like delivered must have all the rows fulfilled but a stage is missing ? 
    --and delivered without status is the delivered timestamp is updated but status is not updated
    -- delivered status is updated but not timestamp essentially 1110 so missing_delivered_stage 
    -- if approved_without_ts + dispatched_Without_ts but these rows tell about which stages have their status updated but not ts?
    --they also could ans this question but this is a bit clean

    {{check_missing_stage('order_stage', 'fulfilled_stages', '1')}} as st_created_missing_stg,
    {{check_missing_stage('order_stage', 'fulfilled_stages', '2')}} as st_approved_missing_stg,
    {{check_missing_stage('order_stage', 'fulfilled_stages', '3')}} as st_invoiced_missing_stg,
    {{check_missing_stage('order_stage', 'fulfilled_stages', '4')}} as st_processing_missing_stg,
    {{check_missing_stage('order_stage', 'fulfilled_stages', '5')}} as st_dispatched_missing_stg,
    {{check_missing_stage('order_stage', 'fulfilled_stages', '6')}} as st_delivered_missing_stg,

 
    {{check_out_of_order_stage('order_stage', 'fulfilled_stages', '1')}} as st_created_out_of_order_stg,
    {{check_out_of_order_stage('order_stage', 'fulfilled_stages', '2')}} as st_approved_out_of_order_stg,
    {{check_out_of_order_stage('order_stage', 'fulfilled_stages', '3')}} as st_invoiced_out_of_order_stg,
    {{check_out_of_order_stage('order_stage', 'fulfilled_stages', '4')}} as st_processing_out_of_order_stg,
    {{check_out_of_order_stage('order_stage', 'fulfilled_stages', '5')}} as st_dispatched_out_of_order_stg,
    {{check_out_of_order_stage('order_stage', 'fulfilled_stages', '6')}} as st_delivered_out_of_order_stg
    
    from base
) 

select * from flagged_table

