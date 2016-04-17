defmodule Meetup.StatisticController do
  use Meetup.Web, :controller

  alias Meetup.Statistics
  alias MeetupApi.V3.Profile

  def topics(conn, %{"group" => group, "page_size" => page_size}) do
    member_topics =
      with {:ok, members} <- Profile.all(group, page_size),
      histogram <- Statistics.topics_histogram(members),
        do: Enum.sort_by(histogram, fn {k, v} -> v end, &>=/2)

    render(conn, "topics.html", topics: member_topics)
  end

  def organizers(conn, %{"group" => group, "page_size" => page_size}) do
    organizer_members =
      with {:ok, members} <- Profile.all(group, page_size),
        do: Statistics.organizers(members)

    render(conn, "organizers.html", organizers: organizer_members)
  end

  def groups(conn, %{"group" => group, "page_size" => page_size}) do
    member_groups =
      with {:ok, members} <- Profile.all(group, page_size),
      histogram <- Statistics.groups_histogram(members),
        do: Enum.sort_by(histogram, fn {k, v} -> v end, &>=/2)

    render(conn, "groups.html", groups: member_groups)
  end
end
