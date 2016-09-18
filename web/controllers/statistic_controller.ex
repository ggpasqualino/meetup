defmodule Meetup.StatisticController do
  use Meetup.Web, :controller

  alias Meetup.Statistics
  alias MeetupApi.V3.Profile

  plug :authenticate_user

  def index(conn, _params) do
    user = get_session(conn, :current_user)
    render(conn, "index.html", user: user)
  end

  def topics(conn, %{"group" => group}) do
    token = conn.assigns.access_token.access_token

    member_topics =
      group
      |> Profile.all(token)
      |> Enum.map(&task(&1, token))
      |> Enum.map(&Task.await(&1, 600_000))
      |> Enum.map(fn {:ok, %{result: result}} -> result end)
      |> Statistics.topics_histogram
      |> Enum.sort_by(fn {k, v} -> v end, &>=/2)

    render(conn, "topics.html", topics: member_topics)
  end

  def organizers(conn, %{"group" => group}) do
    token = conn.assigns.access_token.access_token

    organizer_members =
      group
      |> Profile.all(token)
      |> Enum.map(&task(&1, token))
      |> Enum.map(&Task.await(&1, 600_000))
      |> Enum.map(fn {:ok, %{result: result}} -> result end)
      |> Statistics.organizers

    render(conn, "organizers.html", organizers: organizer_members)
  end

  def groups(conn, %{"group" => group}) do
    token = conn.assigns.access_token.access_token

    member_groups =
      group
      |> Profile.all(token)
      |> Enum.map(&task(&1, token))
      |> Enum.map(&Task.await(&1, 600_000))
      |> Enum.map(fn {:ok, %{result: result}} -> result end)
      |> Statistics.groups_histogram
      |> Enum.sort_by(fn {k, v} -> v end, &>=/2)

    render(conn, "groups.html", groups: member_groups)
  end

  defp task(%{"id" => id}, token) do
    Task.async(fn -> Profile.one(id, token) end)
  end
end
