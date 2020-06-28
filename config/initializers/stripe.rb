Stripe.api_key = Rails.application.credentials[Rails.env.to_sym][:stripe][:secret_key]
STRIPE_WEBHOOK_SECRET = Rails.application.credentials[Rails.env.to_sym][:stripe][:webhook_secret]
FRESHREADER_PRO_MONTHLY_PRICE_ID = Rails.application.credentials[Rails.env.to_sym][:stripe][:freshreader_pro_monthly_price_id]