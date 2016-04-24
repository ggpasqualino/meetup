defmodule Meetup.StatisticController do
  use Meetup.Web, :controller

  alias Meetup.Statistics
  alias MeetupApi.V3.Profile

  def topics(conn, %{"group" => group}) do
    token = get_session(conn, :access_token)

    member_topics =
      group
      |> Profile.all(token)
      |> Statistics.topics_histogram
      |> Enum.sort_by(fn {k, v} -> v end, &>=/2)

    render(conn, "topics.html", topics: member_topics)
  end

  def organizers(conn, %{"group" => group}) do
    token = get_session(conn, :access_token)

    organizer_members =
      group
      |> Profile.all(token)
      |> Statistics.organizers

    render(conn, "organizers.html", organizers: organizer_members)
  end

  def groups(conn, %{"group" => group}) do
    token = get_session(conn, :access_token)

    member_groups =
      group
      |> Profile.all(token)
      |> Statistics.groups_histogram
      |> Enum.sort_by(fn {k, v} -> v end, &>=/2)

    render(conn, "groups.html", groups: member_groups)
  end
end
