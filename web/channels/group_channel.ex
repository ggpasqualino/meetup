defmodule Meetup.GroupChannel do
  @moduledoc false
  use Meetup.Web, :channel

  def join("group:" <> group, params, socket) do
    send(self(), {:after_join, params})
    {:ok, assign(socket, :group, group)}
  end

  def handle_info({:after_join, _params}, socket) do
    channel = socket.assigns.group

    socket.assigns.access_token.access_token
    |> Meetup.ChannelClient.Cache.server_process(channel)
    |> Meetup.ChannelClient.Server.join(socket)

    {:noreply, socket}
  end
end
