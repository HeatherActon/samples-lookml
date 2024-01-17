include: "/views/derived/customer_reference.view"
include: "/views/derived/order_reference.view"
include: "/views/derived/order_item_count_reference.view"
include: "/views/derived/subscription_reference.view"
include: "/views/derived/subscription_item_count_reference.view"
include: "/views/derived/item_reference.view"
include: "/views/refinements/wp_comments_rfn.view"
include: "/views/refinements/wp_eqloyalty_users_rfn.view"
include: "/views/refinements/wp_eqloyalty_history_rfn.view"
include: "/views/refinements/wp_affiliate_wp_referrals_rfn.view"
include: "/views/refinements/wp_affiliate_wp_affiliates_rfn.view"
include: "/views/derived/affiliate_name_reference.view"
include: "/views/refinements/wp_automatewoo_referrals_rfn.view"
include: "/views/refinements/wp_shopname_store_credit_sent_rfn.view"
include: "/views/derived/wp_shopname_store_credit_sent_meta_pivot.view"
include: "/views/refinements/wp_eqtrustpilot_reviews_rfn.view"
include: "/views/refinements/npd_survey_may_2023_rfn.view"
include: "/views/refinements/wp_shopname_typeform_zapier_rfn.view"
include: "/views/derived/quiz_converted_time_reference.view"
include: "/views/refinements/wp_usermeta_rfn.view"
include: "/views/refinements/wp_users_rfn.view"
include: "/views/derived/product_sku_reference.view"
include: "/views/derived/subscription_age_reference.view"
include: "/views/derived/subscription_order_count_reference.view"
include: "/views/derived/order_days_paid_to_arrived.view"

explore: master_explore {
  label: "Master Explore"
  from: customer_reference
  join: order_reference {
    view_label: "Orders"
    type:  left_outer
    sql_on: ${master_explore.user_id} = ${order_reference.customer_id} ;;
    relationship: one_to_many
  }
  join: order_item_reference {
    from: item_reference
    view_label: "Order Items"
    type:  left_outer
    sql_on:  ${order_reference.order_id} = ${order_item_reference.subscription_or_order_id} ;;
    relationship: one_to_many
  }
  join: order_item_count_reference {
    view_label: "Orders"
    type:  left_outer
    sql_on:  ${order_reference.order_id} = ${order_item_count_reference.id} ;;
    relationship: one_to_one
  }
  join: order_product_sku_reference {
    from: product_sku_reference
    view_label: "Order Items"
    type:  left_outer
    sql_on:
      CASE
        WHEN ${order_item_reference.variation_id} = 0
        THEN ${order_item_reference.product_id} = ${order_product_sku_reference.id}
        WHEN ${order_item_reference.variation_id} != 0
        THEN ${order_item_reference.variation_id} = ${order_product_sku_reference.id}
      END ;;
    relationship: many_to_one
  }
  join: order_notes {
    from:  wp_comments
    view_label: "Orders"
    type:  left_outer
    sql_on:  ${order_reference.order_id} = ${order_notes.comment_post_id} ;;
    relationship: one_to_many
  }
  join: order_days_paid_to_arrived {
    view_label: "Orders"
    type:  left_outer
    sql_on:  ${order_reference.order_id} = ${order_days_paid_to_arrived.order_id} ;;
    relationship: one_to_one
  }
  join: subscription_reference {
    view_label: "Subscriptions"
    type:  left_outer
    sql_on: ${master_explore.user_id} = ${subscription_reference.customer_id} ;;
    relationship: one_to_many
  }
  join: subscription_item_reference {
    from: item_reference
    view_label: "Subscription Items"
    type:  left_outer
    sql_on:  ${subscription_reference.subscription_id} = ${subscription_item_reference.subscription_or_order_id} ;;
    relationship: one_to_many
  }
  join: subscription_item_count_reference {
    view_label: "Subscriptions"
    type:  left_outer
    sql_on:  ${subscription_reference.subscription_id} = ${subscription_item_count_reference.id} ;;
    relationship: one_to_many
  }
  join: subscription_product_sku_reference {
    from: product_sku_reference
    view_label: "Subscription Items"
    type:  left_outer
    sql_on:
      CASE
        WHEN ${subscription_item_reference.variation_id} = 0
        THEN ${subscription_item_reference.product_id} = ${subscription_product_sku_reference.id}
        WHEN ${subscription_item_reference.variation_id} != 0
        THEN ${subscription_item_reference.variation_id} = ${subscription_product_sku_reference.id}
      END ;;
    relationship: many_to_one
  }
  join: subscription_notes {
    from:  wp_comments
    view_label: "Subscriptions"
    type:  left_outer
    sql_on:  ${subscription_reference.subscription_id} = ${subscription_notes.comment_post_id} ;;
    relationship: one_to_many
  }
  join: subscription_age_reference {
    view_label: "Subscriptions"
    type:  left_outer
    sql_on: ${subscription_reference.subscription_id} = ${subscription_age_reference.subscription_id} ;;
    relationship: one_to_one
  }
  join: subscription_order_count_reference {
    view_label: "Subscriptions"
    type:  left_outer
    sql_on: ${subscription_reference.subscription_id} = ${subscription_order_count_reference.subscription_id} ;;
    relationship: one_to_one
  }
  join: wp_eqloyalty_users {
    view_label: "Loyalty"
    type:  left_outer
    sql_on:  ${master_explore.user_id} = ${wp_eqloyalty_users.user_id} ;;
    relationship: one_to_many
  }
  join: wp_eqloyalty_history {
    view_label: "Loyalty"
    type:  left_outer
    sql_on:  ${master_explore.user_id} = ${wp_eqloyalty_history.user_id} ;;
    relationship: one_to_many
  }
  join: wp_affiliate_wp_referrals {
    view_label: "Affiliates & Referrals"
    type:  left_outer
    sql_on:  ${order_reference.order_id} = ${wp_affiliate_wp_referrals.reference} ;;
    relationship: many_to_many
  }
  join: wp_affiliate_wp_affiliates {
    view_label: "Affiliates & Referrals"
    type:  left_outer
    sql_on:  ${wp_affiliate_wp_referrals.affiliate_id} = ${wp_affiliate_wp_affiliates.affiliate_id} ;;
    relationship: many_to_one
  }
  join: affiliate_name_reference {
    view_label: "Affiliates & Referrals"
    sql_on:  ${wp_affiliate_wp_affiliates.affiliate_id} = ${affiliate_name_reference.affiliate_id} ;;
    relationship: one_to_one
  }
  #join: wp_eq_ambassador_referrals {
  #  view_label: "Affiliates & Referrals"
  #  type:  left_outer
  #  sql_on:  ${wp_affiliate_wp_affiliates.affiliate_id} = ${wp_eq_ambassador_referrals.affiliate_id} ;;
  #  relationship: one_to_many
  #}
  join: wp_shopname_store_credit_sent {
    view_label: "Store Credit"
    type:  left_outer
    sql_on: ${master_explore.user_id} = ${wp_shopname_store_credit_sent.referee_id} ;;
    relationship: one_to_many
  }
  join: wp_shopname_store_credit_sent_meta_pivot {
    view_label: "Store Credit"
    type: left_outer
    sql_on: ${wp_shopname_store_credit_sent.id} = ${wp_shopname_store_credit_sent_meta_pivot.sent_id} ;;
    relationship: one_to_one
  }
  join: wp_eqtrustpilot_reviews {
    view_label: "Reviews"
    type: left_outer
    sql_on: ${master_explore.user_email} = ${wp_eqtrustpilot_reviews.email} ;;
    relationship: one_to_many
  }
  join: npd_survey_may_2023 {
    view_label: "NPD Survey May 2023"
    type: left_outer
    sql_on: ${master_explore.user_email} = ${npd_survey_may_2023.email} ;;
    relationship: one_to_many
  }
  join: wp_shopname_typeform_zapier {
    view_label: "Quiz"
    type: full_outer
    sql_on: ${master_explore.user_email} = ${wp_shopname_typeform_zapier.email} ;;
    relationship: one_to_many
  }
  join: raf_referrals {
    from: wp_automatewoo_referrals
    view_label: "RAF (Advocate-centric)"
    type:  left_outer
    sql_on:  ${master_explore.user_id} = ${raf_referrals.advocate_id} ;;
    relationship: one_to_one
  }
  join: quiz_converted_time_reference {
    view_label: "Quiz"
    type:  left_outer
    sql_on:  ${master_explore.user_id} = ${quiz_converted_time_reference.user_id} ;;
    relationship: one_to_one
  }
  join: user_meta {
    from: wp_usermeta
    view_label: "Users"
    type:  left_outer
    sql_on: ${master_explore.user_id} = ${user_meta.user_id} ;;
    relationship: one_to_many
  }
  join: wp_users {
    view_label: "Users"
    type:  left_outer
    sql_on: ${master_explore.user_id} = ${wp_users.id} ;;
    relationship: one_to_many
  }
}
