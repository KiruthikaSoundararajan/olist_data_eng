with base as
(
     select f.order_id, f.order_stage,
            s.seq_violation_count,s.missing_ts_count,
            s.ts_lag_count,s.status_lag_count,
            s.unavailable_orders_anomaly,
            s.st_created_miss_stg_cnt,
            s.st_approved_miss_stg_cnt,
            s.st_invoiced_miss_stg_cnt,
            s.st_processing_miss_stg_cnt,
            s.st_dispatched_miss_stg_cnt,
            s.st_delivered_miss_stg_cnt,
            s.st_created_oo_order_stg_cnt,
            s.st_approved_oo_order_stg_cnt,
            s.st_invoiced_oo_order_stg_cnt,
            s.st_processing_oo_order_stg_cnt,
            s.st_dispatched_oo_order_stg_cnt,
            s.st_delivered_oo_order_stg_cnt
     from {{ref('int_orders_flagged')}} as f 
     INNER JOIN {{ref('int_orders_summary')}} as s
     on f.order_id=s.order_id

),

analysis_table as
(
     select
     {{calculate_rate('seq_violation_count','> 0')}} as err_seq_rate,
     avg(case when missing_ts_count> 0 then 1.0 else 0.0 end) * 100.0 as missing_rows_rate,
     {{calculate_rate('ts_lag_count+status_lag_count','> 0')}} status_ts_mismatch_rate,
     {{calculate_rate('unavailable_orders_anomaly','is not null')}} as unavailable_anomaly_rate,

     {{stg_seq_rate('st_created_miss_stg_cnt','order_stage','0')}}  as   created_miss_stg_rate,
     {{stg_seq_rate('st_approved_miss_stg_cnt','order_stage','1')}} as  approved_miss_stg_rate,
     {{stg_seq_rate('st_invoiced_miss_stg_cnt','order_stage','2')}}  as   invoiced_miss_stg_rate,
     {{stg_seq_rate('st_processing_miss_stg_cnt','order_stage','3')}} as  processing_miss_stg_rate,
     {{stg_seq_rate('st_dispatched_miss_stg_cnt','order_stage','4')}} as  dispatched_miss_stg_rate,
     {{stg_seq_rate('st_delivered_miss_stg_cnt','order_stage','5')}} as  delivered_miss_stg_rate,

     {{stg_seq_rate('st_created_oo_order_stg_cnt','order_stage','0')}}  as   created_ooo_stg_rate,
     {{stg_seq_rate('st_approved_oo_order_stg_cnt','order_stage','1')}} as  approved_ooo_stg_rate,
     {{stg_seq_rate('st_invoiced_oo_order_stg_cnt','order_stage','2')}}  as   invoiced_ooo_stg_rate,
     {{stg_seq_rate('st_processing_oo_order_stg_cnt','order_stage','3')}} as  processing_ooo_stg_rate,
     {{stg_seq_rate('st_dispatched_oo_order_stg_cnt','order_stage','4')}} as  dispatched_ooo_stg_rate,
     {{stg_seq_rate('st_delivered_oo_order_stg_cnt','order_stage','5')}} as  delivered_ooo_stg_rate
     from base
)

select * from analysis_table