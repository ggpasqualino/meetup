defmodule Meetup.StatisticController do
  use Meetup.Web, :controller

  alias Meetup.Statistics
  alias MeetupApi.V3.Profile

  def topics(conn, %{"group" => group}) do
    member_topics =
      group
      |> Profile.all
      |> Statistics.topics_histogram
      |> Enum.sort_by(fn {k, v} -> v end, &>=/2)

    render(conn, "topics.html", topics: member_topics)
  end

  def organizers(conn, %{"group" => group}) do
    organizer_members =
      group
      |> Profile.all
      |> Statistics.organizers

    render(conn, "organizers.html", organizers: organizer_members)
  end

  def groups(conn, %{"group" => group}) do
    member_groups =
      group
      |> Profile.all
      |> Statistics.groups_histogram
      |> Enum.sort_by(fn {k, v} -> v end, &>=/2)

    render(conn, "groups.html", groups: member_groups)
  end
end
