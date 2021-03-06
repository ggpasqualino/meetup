# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :meetup, Meetup.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XVM6/VcNY8bAwfnl2RUR5TRhZ77AAI6nsanOsuifNY63eC6nEKoCqty9eEJ0skA4",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Meetup.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :meetup, :oauth,
  client_id: "${MEETUP_CLIENT_ID}",
  client_secret: "${MEETUP_CLIENT_SECRET}",
  redirect_uri: "${MEETUP_REDIRECT_URI}"

config :meetup,
  user_expiration_time: 3600

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
