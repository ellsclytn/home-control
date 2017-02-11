defmodule Thermio.AirconController do
  use Thermio.Web, :controller

  def index(conn, _params) do
    json conn, %{id: "status"}
  end
end
