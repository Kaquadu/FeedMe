defmodule FeedWeb.Router do
  use FeedWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug FeedWeb.SessionExpirationPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FeedWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/session" do
      resources "/", SessionController, only: [:new, :create, :delete]
    end

    scope "/user" do
      resources "/", Auth.UserController, except: [:index]
      get "/confirm/:id", Auth.UserController, :confirm_email
    end

    live "/product", ProductLive, layout: {FeedWeb.LayoutView, "live.html"}
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # Other scopes may use custom stacks.
  # scope "/api", FeedWeb do
  #   pipe_through :api
  # end
end
