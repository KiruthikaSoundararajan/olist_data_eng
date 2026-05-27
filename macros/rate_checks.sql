{% macro calculate_rate(column,condition) %}
    ((count(*) filter(where {{column}} {{condition}}))::float / nullif(count(*),0)) * 100.0
{% endmacro %}


{% macro stg_seq_rate(column,order_stage,stage_value) %}
    ((count(*) filter(where {{column}} is not null or {{column}}>0))::float
    
     / nullif(count(*) filter(where {{order_stage}} = {{stage_value}}),0)) * 100

{% endmacro %}