defmodule Thermio.Router do
  use Thermio.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ProperCase.Plug.SnakeCaseParams
    plug Joken.Plug,
      verify: &Thermio.JWTHelpers.verify/0,
      on_error: &Thermio.JWTHelpers.error/2
  end

  scope "/", Thermio do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

  end

  scope "/auth", Thermio do
    pipe_through :browser

    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
  end

  scope "/api", Thermio do
    pipe_through :api

    get "/climates/:date", ClimateController, :index_by_date
    get "/climates/:start_date/:end_date", ClimateController, :index_by_dates
    resources "/climates", ClimateController, except: [:create, :new, :edit]

    post "/aircon/dialogflow", AirconController, :handle_dialogflow
    resources "/aircon", AirconController, except: [:new, :edit]
  end

  scope "/health", Thermio do
    get "/", HealthController, :health
  end
end
