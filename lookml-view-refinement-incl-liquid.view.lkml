include: "/views/base/wp_postmeta.view"

view: +wp_postmeta {

  dimension: post_id {
    hidden: yes
  }

  dimension: meta_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.meta_id ;;
  }

  dimension: meta_value {
    label: "Meta (string)"
  }

  dimension: meta_value_num {
    label: "Meta (number)"
    type: number
    sql: CAST(${meta_value} as FLOAT64);;
  }

  dimension: meta_value_date {
    label: "Meta (date)"
    type: date
    convert_tz: no
    
    sql: IF( ${meta_value} != '0', LEFT(${meta_value}, 10), '2000-01-01' ) ;;
  }

  measure: count {
    hidden: yes
  }

  measure: sum {
    label: "
    {% if _explore._name == 'orders' %}
    Order Meta Sum
    {% elsif _explore._name == 'subscriptions' %}
    Subscription Meta Sum
    {% else %}
    Count
    {% endif %}
    "
    type: sum
    sql: ${meta_value_num} ;;
    value_format_name: usd
  }

  measure: average {
    label: "
    {% if _explore._name == 'orders' %}
    Order Meta Average
    {% elsif _explore._name == 'subscriptions' %}
    Subscription Meta Average
    {% else %}
    Count
    {% endif %}
    "
    type: average
    sql: ${meta_value_num} ;;
  }

}
