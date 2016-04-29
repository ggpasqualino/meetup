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
    token = conn.assigns.access_token
    if token do
      validate_token(token, conn)
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt
    end
  end

  def validate_token(token, conn) do
    if MeetupApi.V3.OAuth.token_expired?(token) do
      conn
      |> logout
      |> put_flash(:error, "Session expired!")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt
    else
      conn
    end
  end

  def login(conn, access_token, user) do
    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, access_token)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> delete_session(:current_user)
    |> delete_session(:access_token)
  end
end
