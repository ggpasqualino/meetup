defmodule Meetup.SessionController do
  use Meetup.Web, :controller

  alias MeetupApi.V3.OAuth

  def create(conn, _params) do
    redirect(conn, external: OAuth.authorize_url!)
  end

  def callback(conn, %{"code" => code}) do
    token = OAuth.get_token!(code: code).token

    conn
    |> Meetup.Auth.login(token, user(token.access_token))
    |> put_flash(:info, "Welcome!")
    |> redirect(to: page_path(conn, :index))
  end

  def callback(conn, %{"error" => error}) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: page_path(conn, :index))
  end

  def delete(conn, _params) do
    conn
    |> Meetup.Auth.logout
    |> redirect(to: page_path(conn, :index))
  end

  defp user(token) do
    {:ok, %{result: member}} = MeetupApi.V3.Profile.one("self", token)

    memberships = Map.get(member, "memberships", %{})

    groups =
      memberships
      |> Map.get("organizer", [])
      |> Kernel.++(Map.get(memberships, "member", []))
      |> Enum.map(&get_in(&1, ["group", "urlname"]))
      |> Enum.sort

    %{name: member["name"], groups: groups}
  end
end
