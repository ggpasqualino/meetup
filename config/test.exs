use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :meetup, Meetup.Endpoint,
  http: [port: 4001],
  server: false

config :meetup, Strangled.Server,
  max_rate: 1,
  time_interval: 1,
  user_expiration_time: 4

  config :meetup, MeetupApi.Server,
  seconds_to_reset: 1,
  user_expiration_time: 4

# Print only warnings and errors during test
config :logger, level: :warn
