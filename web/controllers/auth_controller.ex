defmodule Meetup.AuthController do
  use Meetup.Web, :controller

  alias MeetupApi.V3.OAuth

  def index(conn, _params) do
    redirect(conn, external: OAuth.authorize_url!)
  end

  def callback(conn, %{"code" => code}) do
    token = OAuth.get_token!(code: code)

    conn
    |> put_session(:access_token, token.access_token)
    |> redirect(to: "/")
  end
end
