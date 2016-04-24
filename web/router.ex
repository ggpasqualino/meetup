defmodule Meetup.Router do
  use Meetup.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Meetup do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/statistic", Meetup do
    pipe_through :browser

    get "/topics", StatisticController, :topics
    get "/organizers", StatisticController, :organizers
    get "/groups", StatisticController, :groups
  end

  scope "/auth", Meetup do
    pipe_through :browser

    get "/meetup", AuthController, :index
    get "/meetup/callback", AuthController, :callback
  end
end
