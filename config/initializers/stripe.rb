Rails.configuration.stripe = {
  :publishable_key => 'pk_test_PPBuEX4eZSmtOMWUKGWDy9Xs',
  :secret_key      => 'sk_test_mQoabU8FsBTnTZ2xQxCSrTj2'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]