defmodule Thermio.AirconController do
  use Thermio.Web, :controller

  def subscribe do
    topics = ["climate"]
    qoses = [0]
    callback_fn = fn(_) -> nil end
    Bus.Mqtt.subscribe(topics, qoses, callback_fn)
  end

  def store_climate(message) do
    Poison.decode!(message)
    |> IO.inspect
  end

  def index(conn, _params) do
    json conn, %{id: "status"}
  end
end
