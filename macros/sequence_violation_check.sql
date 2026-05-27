{% macro stage_sequence_violation(current_stage, previous_stage) %}
    case 
       when {{current_stage}} is null or {{previous_stage}} is null then null
       when {{current_stage}} < {{previous_stage}} then 1
       else 0
    end
{% endmacro %}