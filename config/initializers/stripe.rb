Rails.configuration.stripe = {
  :publishable_key => 'pk_live_Q3Xa5ZvHkLO3eJbRARlT5W7g',
  :secret_key      => 'sk_live_g8QQm1TzQYGo13DW9kruIjvf'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]