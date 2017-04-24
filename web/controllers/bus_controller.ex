defmodule Bus.Callback do
  def on_connect(data) do
    IO.inspect data
  end

  def on_disconnect(data) do
    IO.inspect data
  end

  def on_error(data) do
    IO.inspect data
  end

  def on_info(data) do
    IO.inspect data
  end

  def on_message_received(topic, message) do
    case topic do
      "climate" ->
        Thermio.AirconController.store_climate(message)
    end
  end
end
