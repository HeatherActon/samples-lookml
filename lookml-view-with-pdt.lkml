view: order_reference {
  label: "Orders"
  derived_table: {
    sql: SELECT wp_postmeta.post_id as `Order ID`,
        wp_posts.post_status as `Status`,
        wp_posts.post_date_gmt as `Order Date`,
        max(case when wp_postmeta.meta_key = '_customer_user' then CAST(meta_value as INT64) end) as `Customer ID`,
        max(case when wp_postmeta.meta_key = '_created_via' then meta_value end) as `Created Via`,
        max(case when wp_postmeta.meta_key = 'order_contents' then meta_value end) as `Order Contents`,
        max(case when wp_postmeta.meta_key = 'order_contents' then (
            case when meta_value IN ('renewal_of_sub','renewal_incl_otp') then 'renewal'
                 when meta_value IN ('otp_only','giftcard_only') then 'one-time purchase'
                 when meta_value IN ('parent_sub_only','parent_sub_incl_otp','parent_sub_order_incl_otp','parent_sub_order_sub_only') then 'parent'
            end)
          end) as `Order Type`,
        max(case when wp_postmeta.meta_key = '_cart_discount' then CAST(meta_value AS FLOAT64) end) as `Order Discount`,
        max(case when wp_postmeta.meta_key = '_cart_discount_tax' then CAST(meta_value AS FLOAT64) end) as `Order Discount Tax`,
        max(case when wp_postmeta.meta_key = '_order_shipping' then CAST(meta_value AS FLOAT64) end) as `Order Shipping`,
        max(case when wp_postmeta.meta_key = '_order_shipping_tax' then CAST(meta_value AS FLOAT64) end) as `Order Shipping Tax`,
        max(case when wp_postmeta.meta_key = '_order_tax' then CAST(meta_value AS FLOAT64) end) as `Order Tax`,
        max(case when wp_postmeta.meta_key = '_order_total' then CAST(meta_value AS FLOAT64) end) as `Order Total`,
        max(case when wp_postmeta.meta_key = 'first_purchase' then meta_value end) as `First Purchase`,
        max(case when wp_postmeta.meta_key = 'is_grad' then meta_value end) as `Is Grad`,
        max(case when wp_postmeta.meta_key = 'is_winback' then meta_value end) as `Is Winback`,
        max(case when wp_postmeta.meta_key = 'is_clawback' then meta_value end) as `Is Clawback`,
        max(case when wp_postmeta.meta_key = 'otp_type' then meta_value end) as `OTP Type`,
        max(case when wp_postmeta.meta_key = 'order_origin' then meta_value end) as `Order Origin`,
        max(case when wp_postmeta.meta_key = '_subscription_renewal' then CAST(meta_value as INT64) end) as `Subscription ID`,
        max(case when wp_postmeta.meta_key = 'pf_quiz_converted' then (CASE WHEN meta_value != '0' THEN PARSE_DATETIME('%Y-%m-%d %H:%M:%S', meta_value)
        ELSE NULL END) end) as `Product Finder Quiz Converted`,
        max(case when wp_postmeta.meta_key = 'loyalty_points' then CAST(meta_value as INT64) end) as `Loyalty Points`,
        max(case when wp_postmeta.meta_key = '_taxjar_sync_last_error' then meta_value end) as `Taxjar Error`,
        STRING_AGG(DISTINCT wp_woocommerce_order_items.order_item_name) as `Coupons Applied`
      FROM wp_postmeta
      LEFT JOIN wp_posts ON wp_posts.ID = wp_postmeta.post_id
      LEFT JOIN wp_woocommerce_order_items on wp_posts.ID = wp_woocommerce_order_items.order_id
      WHERE wp_posts.post_type = 'shop_order'
      GROUP BY post_id,post_status,post_date_gmt
      ORDER BY post_id DESC
      ;;
    datagroup_trigger: myeq_default_datagroup
  }

  measure: count {
    label: "Count of Orders"
    type: count
    drill_fields: [detail*]
  }

  measure: average_order_total {
    label: "Average Order Total ($)"
    type: average
    sql: ${order_total} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: average_order_discount {
    label: "Average Order Discount ($)"
    type: average
    sql: ${order_discount} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: average_order_net_revenue {
    label: "Average Order Net Revenue ($)"
    type: average
    sql: ${order_net_revenue} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: average_order_gross_revenue {
    label: "Average Order Gross Revenue ($)"
    type: average
    sql: ${order_gross_revenue} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: average_order_discount_rate {
    label: "Average Order Discount Rate (%)"
    type: average
    sql: ${order_discount_rate} ;;
    drill_fields: [detail*]
    value_format_name: percent_2
  }

  measure: sum_order_total {
    label: "Sum Order Totals ($)"
    type: sum
    sql: ${order_total} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: sum_order_discount {
    label: "Sum Order Discounts ($)"
    type: sum
    sql: ${order_discount} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: sum_order_net_revenue {
    label: "Sum Order Net Revenue ($)"
    type: sum
    sql: ${order_net_revenue} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: sum_order_gross_revenue {
    label: "Sum Order Gross Revenue ($)"
    type: sum
    sql: ${order_gross_revenue} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: sum_order_shipping {
    label: "Sum Order Shipping ($)"
    type: sum
    sql: ${order_shipping} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: sum_order_tax {
    label: "Sum Order Tax ($)"
    type: sum
    sql: ${order_tax} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: total_loyalty_points {
    label: "Total Loyalty Points"
    type: sum
    sql: ${loyalty_points} ;;
    drill_fields: [detail*]
  }

  dimension: order_id {
    primary_key: yes
    type: number
    label: "Order ID"
    sql: ${TABLE}.`Order ID` ;;
  }

  dimension: status {
    type: string
    label: "Status"
    sql: ${TABLE}.`Status` ;;
  }

  dimension_group: order_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    label: "Order (America/Chicago)"
    sql: ${TABLE}.`Order Date` ;;
  }

  dimension: customer_id {
    hidden: yes
    type: number
    label: "Customer ID"
    sql: ${TABLE}.`Customer ID` ;;
  }

  dimension: created_via {
    type: string
    label: "Created Via"
    sql: ${TABLE}.`Created Via` ;;
    description: "checkout|admin|subscription|rest-api"
  }

  dimension: order_contents {
    type: string
    label: "Order Contents"
    group_label: "Meta"
    sql: ${TABLE}.`Order Contents` ;;
    description: "renewal_of_sub|otp_only|parent_sub_only|renewal_incl_otp|parent_sub_incl_otp|parent_sub_order_incl_otp|parent_sub_order_sub_only|giftcard_only"
  }

  dimension: order_type {
    type: string
    label: "Order Type"
    sql: ${TABLE}.`Order Type` ;;
    description: "renewal|parent|one-time purchase"
  }

  dimension: order_discount {
    type: number
    label: "Order Discount"
    group_label: "Financials"
    sql: ${TABLE}.`Order Discount` ;;
    value_format_name: usd
  }

  dimension: order_discount_tax {
    type: number
    label: "Order Discount Tax"
    group_label: "Financials"
    sql: ${TABLE}.`Order Discount Tax` ;;
    value_format_name: usd
  }

  dimension: order_shipping {
    type: number
    label: "Order Shipping"
    group_label: "Financials"
    sql: ${TABLE}.`Order Shipping` ;;
    value_format_name: usd
  }

  dimension: order_shipping_tax {
    type: number
    label: "Order Shipping Tax"
    group_label: "Financials"
    sql: ${TABLE}.`Order Shipping Tax` ;;
    value_format_name: usd
  }

  dimension: order_tax {
    type: number
    label: "Order Tax"
    group_label: "Financials"
    sql: ${TABLE}.`Order Tax` ;;
    value_format_name: usd
  }

  dimension: order_total {
    type: number
    label: "Order Total"
    group_label: "Financials"
    sql: ${TABLE}.`Order Total` ;;
    value_format_name: usd
  }

  dimension: order_net_revenue {
    type: number
    label: "Order Net Revenue"
    group_label: "Financials"
    sql: ${order_total} - ${order_tax} - ${order_shipping} - ${order_shipping_tax};;
    value_format_name: usd
    description: "total - tax - shipping"
  }

  dimension: order_gross_revenue {
    type: number
    label: "Order Gross Revenue"
    group_label: "Financials"
    sql: ${order_total} - ${order_tax} + ${order_discount} - ${order_shipping} - ${order_shipping_tax};;
    value_format_name: usd
    description: "total + discount - tax - shipping"
  }

  dimension: order_discount_rate{
    type: number
    label: "Order Discount Rate"
    group_label: "Financials"
    sql: ${order_discount}/NULLIF(${order_gross_revenue},0);;
    value_format_name: percent_2
    description: "discount / gross"
  }

  dimension: first_purchase {
    type: string
    label: "First Purchase"
    group_label: "Meta"
    sql: ${TABLE}.`First Purchase` ;;
    description: "yes|no"
  }

  dimension: is_grad {
    type: string
    label: "Is Grad"
    group_label: "Meta"
    sql: ${TABLE}.`Is Grad` ;;
    description: "yes|no"
  }

  dimension: is_winback {
    type: string
    label: "Is Winback"
    group_label: "Meta"
    sql: ${TABLE}.`Is Winback` ;;
    description: "yes|no"
  }

  dimension: is_clawback {
    type: string
    label: "Is Clawback"
    group_label: "Meta"
    sql: ${TABLE}.`Is Clawback` ;;
    description: "yes|no"
  }

  dimension: otp_type {
    type: string
    label: "OTP Type"
    group_label: "Meta"
    sql: ${TABLE}.`OTP Type` ;;
    description: "nongrad_new|nongrad_repeat|active_otp|cancelled_otp"
  }

  dimension: order_origin {
    type: string
    label: "Order Origin"
    group_label: "Meta"
    sql: ${TABLE}.`Order Origin` ;;
    description: "myeq|discovermyeq"
  }

  dimension: subscription_id {
    type: number
    label: "Subscription ID"
    sql: ${TABLE}.`Subscription ID` ;;
  }

  dimension: loyalty_points {
    type: number
    label: "Loyalty Points"
    sql: ${TABLE}.`Loyalty Points` ;;
  }

  dimension: taxjar_error {
    type: string
    label: "Taxjar Error"
    group_label: "Meta"
    sql: ${TABLE}.`Taxjar Error` ;;
  }

  dimension: coupons_applied {
    type: string
    label: "Coupons Applied"
    sql: ${TABLE}.`Coupons Applied` ;;
  }

  dimension_group: pf_quiz_converted_date {
    type: time
    datatype: datetime
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    label: "Product Finder Quiz Converted (America/Chicago)"
    sql: ${TABLE}.`Product Finder Quiz Converted` ;;
    convert_tz: no
  }

  set: detail {
    fields: [
      order_id,
      order_date_time,
      customer_id,
      created_via,
      order_contents,
      order_discount,
      order_discount_tax,
      order_shipping,
      order_shipping_tax,
      order_tax,
      order_total,
      first_purchase,
      is_grad,
      is_winback,
      is_clawback,
      otp_type,
      order_origin,
      subscription_id
    ]
  }
}
