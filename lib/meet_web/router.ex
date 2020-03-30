defmodule MeetWeb.Router do
  use MeetWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MeetWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/user" do
      resources "/", Auth.UserController, except: [:index]
      get "/confirm/:id", Auth.UserController, :confirm_email
    end
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # Other scopes may use custom stacks.
  # scope "/api", MeetWeb do
  #   pipe_through :api
  # end
end
