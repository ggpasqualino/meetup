defmodule Meetup.UserSocket do
  @moduledoc false

  use Phoenix.Socket
  alias Phoenix.Token
  alias MeetupApi.V3.OAuth

  transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000

  channel "group:*", Meetup.GroupChannel

  def connect(%{"channel_token" => token}, socket) do
    with  {:ok, access_token} <- Token.verify(socket, "channel_token", token),
      false <- OAuth.token_expired?(access_token)
    do
      socket = assign(socket, :access_token, access_token)
      {:ok, socket}
    else
      _ -> :error
    end
  end

  def id(socket), do: socket.assigns.access_token.access_token
end
