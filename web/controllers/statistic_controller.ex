defmodule Meetup.StatisticController do
  use Meetup.Web, :controller

  alias Meetup.Member
  alias Meetup.Statistics

  def topics(conn, _params) do
    member_topics =
      Member
      |> Repo.all
      |> Statistics.topics_histogram
      |> Enum.sort_by(fn {k, v} -> v end, &>=/2)

    render(conn, "topics.html", topics: member_topics)
  end

  def organizers(conn, _params) do
    organizer_members =
      Member
      |> Repo.all
      |> Statistics.organizers

    render(conn, "organizers.html", organizers: organizer_members)
  end

  def groups(conn, _params) do
    member_groups =
      Member
      |> Repo.all
      |> Statistics.groups_histogram
      |> Enum.sort_by(fn {k, v} -> v end, &>=/2)

    render(conn, "groups.html", groups: member_groups)
  end
end
