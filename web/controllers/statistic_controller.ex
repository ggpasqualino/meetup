defmodule Meetup.StatisticController do
  use Meetup.Web, :controller

  plug :authenticate_user

  def index(conn, _params) do
    user = get_session(conn, :current_user)
    render(conn, "index.html", user: user)
  end

  def topics(conn, %{"group" => group}) do
    render(conn, "statistics.html", title: "Topics", group: group, statistic: "topics")
  end

  def organizers(conn, %{"group" => group}) do
    render(conn, "statistics.html", title: "Organizers", group: group, statistic: "organizers")
  end

  def groups(conn, %{"group" => group}) do
    render(conn, "statistics.html", title: "Groups", group: group, statistic: "groups")
  end
end
