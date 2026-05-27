{% macro missing_value_check(column) %}
    case 
       when {{column}} is null then 1 
       else 0 
    end
{% endmacro %} 

{% macro filled_value_check(column) %}
    case 
       when {{column}} is not null then 1 
       else 0 
    end
{% endmacro %} 

{% macro status_without_ts(order_stage, stage_threshold, missing_ts_column) %}
   case 
      when  {{order_stage}} = 0 then null
      when  {{order_stage}} >= {{stage_threshold}} and {{missing_ts_column}} = 1 then 1
      else 0
   end 
{% endmacro %}

{% macro ts_without_status(order_stage, stage_threshold, missing_ts_column) %}
   case
      when  {{order_stage}} = 0 then null
      when  {{order_stage}} < {{stage_threshold}} and {{missing_ts_column}} = 0 then 1
      else 0
   end 
{% endmacro %}


{% macro check_stage_presence(order_stage, fulfilled_stages, stage_value, stage_criterion) %}
  
  
   case
      when {{order_stage}} != {{stage_value}} then null
      when {{order_stage}} = {{stage_value}} and {{fulfilled_stages}} = {{stage_criterion}} then 1
      else -1
   end
{% endmacro %}

{% macro check_missing_stage(order_stage , fulfilled_stages , stage_value) %}
    
    {%-
    set masks = {
      1:  "B'1000'",
      2:  "B'1100'",
      3:  "B'1100'",
      4:  "B'1100'",
      5:  "B'1110'",
      6:  "B'1111'"
      }
    -%}

    {%- set temp = masks.get(stage_value|int,"B:'1111'") -%}      
    
    case when {{order_stage}} != {{stage_value}} then null 
    else
    (
      with masked as 
      (

        select (~({{fulfilled_stages}}::bit(4)) & {{temp}}) as m
                    
      )
      select 
        concat_ws(',',
          case when ~m  & {{temp}} = {{temp}} then 'no_missing_stage' end,
          case when m  & B'1000' = B'1000' then 'purchase' end ,
          case when m  & B'0100' = B'0100' then 'approval' end,
          case when m  & B'0010' = B'0010' then 'dispatch' end, 
          case when m  & B'0001' = B'0001' then 'delivery' end
          ) 
      from masked
    )
    end

{% endmacro %}

{% macro missing_stage_count(order_stage , fulfilled_stages , stage_value) %}
    
    {%-
    set masks = {
      1:  "B'1000'",
      2:  "B'1100'",
      3:  "B'1100'",
      4:  "B'1100'",
      5:  "B'1110'",
      6:  "B'1111'"
      }
    -%}

    {%- set temp = masks.get(stage_value|int,"B:'1111'") -%}      
    
    case when {{order_stage}} != {{stage_value}} then null 
    else
    (
      with masked as 
      (

        select (~({{fulfilled_stages}}::bit(4)) & {{temp}}) as m
                    
      )
      select 
          case when ~m  & {{temp}} = {{temp}} then 0
          else
            (case when m  & B'1000' = B'1000' then 1 end +
             case when m  & B'0100' = B'0100' then 1 end +
             case when m  & B'0010' = B'0010' then 1 end +
             case when m  & B'0001' = B'0001' then 1 end
            ) 
          end
      from masked
    )
    end

{% endmacro %}
        

{% macro check_out_of_order_stage(order_stage , fulfilled_stages , stage_value) %}

    {%- set masks = 
     { 1: "B'0111'",
       2: "B'0011'",
       3: "B'0011'",
       4: "B'0011'",
       5: "B'0001'",
       6: "B'0000'"}
    -%}
    
    {%- set temp = masks.get(stage_value | int, "B'1111'") -%}

    case when {{order_stage}} != {{stage_value}} then null
    else
    ( 
      with masked as 
      (
          select {{fulfilled_stages}} & {{temp}} as m
      )
    
      select 
        concat_ws(
        ',',
        case when ~m & {{temp}} = {{temp}} then 'in_order' end,
        case when m & B'1000' = B'1000' then 'purchase' end ,
        case when m & B'0100' = B'0100' then 'approval' end ,
        case when m & B'0010' = B'0010' then 'dispatch' end ,
        case when m & B'0001' = B'0001' then 'delivery' end) 
      from masked
    )
    end
{% endmacro %}
  
{% macro out_of_order_stage_count(order_stage , fulfilled_stages , stage_value) %}
 
      {%- set masks = 
       {
          1:"B'0111'",
          2:"B'0011'",
          3:"B'0011'",
          4:"B'0011'",
          5:"B'0001'",
          6:"B'0000'"

       } -%}

      {%- set temp = masks.get(stage_value | int , "B'1111'" ) -%}

      
   case when {{order_stage}} != {{stage_value}} then null
    else
    ( 
      with masked as 
      (
          select {{fulfilled_stages}} & {{temp}} as m
      )
    
      select 
       
         case 
            when ~m & {{temp}} = {{temp}} then 0 
         else
            (case when m & B'1000' = B'1000' then 1 end +
            case when m & B'0100' = B'0100' then 1 end +
            case when m & B'0010' = B'0010' then 1 end +
            case when m & B'0001' = B'0001' then 1 end) 
         end
      from masked
    )
    end
{% endmacro %} 
         

       