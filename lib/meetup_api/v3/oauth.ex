defmodule MeetupApi.V3.OAuth do
  use OAuth2.Strategy

  alias MeetupApi.V3.Api

  # Public API

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: :meetup |> Application.get_env(:oauth) |> Keyword.get(:client_id),
      client_secret: :meetup |> Application.get_env(:oauth) |> Keyword.get(:client_secret),
      redirect_uri: :meetup |> Application.get_env(:oauth) |> Keyword.get(:redirect_uri),
      site: Api.endpoint,
      authorize_url: "https://secure.meetup.com/oauth2/authorize",
      token_url: "https://secure.meetup.com/oauth2/access"
    ])
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: "basic")
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  def token_expired?(token) do
    OAuth2.AccessToken.expired?(token)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
