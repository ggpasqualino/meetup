use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :meetup, Meetup.Endpoint,
  http: [port: 4001],
  server: false

config :meetup,
  user_expiration_time: 4

# Print only warnings and errors during test
config :logger, level: :warn
