use Mix.Config

config :meetup, Meetup.Endpoint,
  http: [port: "${PORT}"],
  url: [scheme: "${URL_SCHEME}", host: "${URL_HOST}", port: "${PORT}"],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: "${SECRET_KEY_BASE}",
  server: true,
  root: ".",
  version: Application.spec(:meetup, :vsn)

if "${URL_SCHEME}" == "https" do
  config :meetup, Meetup.Endpoint, force_ssl: [rewrite_on: [:x_forwarded_proto]]
end

config :logger, level: :info
