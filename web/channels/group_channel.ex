defmodule Meetup.GroupChannel do
  @moduledoc false
  use Meetup.Web, :channel

  alias MeetupApi.V3.Profile

  def join("group:" <> group, params, socket) do
    send(self(), {:after_join, params})
    {:ok, assign(socket, :group, group)}
  end

  def handle_info({:after_join, _params}, socket) do
    token = socket.assigns.access_token.access_token

    socket.assigns.group
    |> Profile.all(token)
    |> send_total_members(socket)
    |> Enum.each(fn(%{"id" => id}) ->
      {:ok, %{result: member}} = Profile.one(id, token)
      push(socket, "member", %{member: member})
    end)

    {:noreply, socket}
  end

  defp send_total_members(members, socket) do
    push(socket, "total_members", %{total_members: length(members)})
    members
  end
end
