defmodule Meetup.Router do
  use Meetup.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Meetup.Auth
  end

  scope "/", Meetup do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/stats", Meetup do
    pipe_through :browser

    get "/index", StatisticController, :index
    get "/:group/topic", StatisticController, :topics
    get "/:group/organizer", StatisticController, :organizers
    get "/:group/group", StatisticController, :groups
  end

  scope "/auth", Meetup do
    pipe_through :browser

    get "/meetup", SessionController, :create
    get "/meetup/callback", SessionController, :callback
    get "/meetup/delete", SessionController, :delete
  end
end
