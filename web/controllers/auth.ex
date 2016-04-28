defmodule Meetup.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias Meetup.Router.Helpers

  def init(_opts) do
  end

  def call(conn, _opts) do
    token = get_session(conn, :access_token)
    assign(conn, :access_token, token)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.access_token do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt
    end
  end

  def login(conn, access_token, user) do
    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, access_token)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
