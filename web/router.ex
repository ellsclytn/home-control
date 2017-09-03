defmodule Thermio.Router do
  use Thermio.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug ProperCase.Plug.SnakeCaseParams
    plug Joken.Plug,
      verify: &Thermio.JWTHelpers.verify/0,
      on_error: &Thermio.JWTHelpers.error/2
  end

  pipeline :webhook do
    plug :accepts, ["json"]
    plug ProperCase.Plug.SnakeCaseParams
  end

  scope "/webhook", Thermio do
    pipe_through :webhook

    resources "/messages", MessageController, except: [:new, :edit, :delete, :update, :index]
  end


  scope "/api", Thermio do
    pipe_through :api

    get "/climates/:date", ClimateController, :index_by_date
    get "/climates/:start_date/:end_date", ClimateController, :index_by_dates
    resources "/climates", ClimateController, except: [:create, :new, :edit]
    resources "/aircon", AirconController, except: [:new, :edit]
  end

  scope "/health", Thermio do
    get "/", HealthController, :health
  end
end
