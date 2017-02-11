defmodule Thermio.Router do
  use Thermio.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Thermio do
    pipe_through :api

    get "/aircon", AirconController, :index
  end
end
