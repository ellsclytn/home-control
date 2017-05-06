defmodule Thermio.Router do
  use Thermio.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug ProperCase.Plug.SnakeCaseParams
    plug Joken.Plug,
      verify: &Thermio.JWTHelpers.verify/0,
      on_error: &Thermio.JWTHelpers.error/2
  end

  scope "/api", Thermio do
    pipe_through :api

    get "/climates/:date", ClimateController, :index_by_date
    get "/climates/:start_date/:end_date", ClimateController, :index_by_dates
    resources "/climates", ClimateController, except: [:create, :new, :edit]
    resources "/aircon", AirconController, except: [:new, :edit]
    resources "/soils", SoilController, except: [:create, :new, :edit, :update]
  end

  scope "/health", Thermio do
    get "/", HealthController, :health
  end
end
