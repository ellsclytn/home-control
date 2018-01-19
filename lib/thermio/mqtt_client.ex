defmodule Thermio.MqttClient do
  require Logger
  use GenMQTT

  defp config do
    Application.get_env(:thermio, Thermio.Endpoint)[:mqtt]
  end

  def start_link do
    GenMQTT.start_link(__MODULE__, nil, [
      name: :mqtt,
      host: config()[:host],
      password: config()[:password],
      port: config()[:port],
      reconnect_timeout: 5,
      username: config()[:username],
    ])
  end

  def on_connect(state) do
    Logger.info("Connected to MQTT host #{config()[:host]}")
    :ok = GenMQTT.subscribe(Process.whereis(:mqtt), config()[:queues])

    {:ok, state}
  end

  def on_disconnect(state) do
    Logger.info("Disconnected from MQTT host #{config()[:host]}")
    
    {:ok, state}
  end

  def on_publish([topic], message, state) do
    case topic do
      "climate" ->
        Thermio.ClimateController.create_from_json(message)
      _ ->
        Logger.warn("Invalid topic #{topic}")
    end

    {:ok, state}
  end

  def publish_message(topic, message) do
    GenMQTT.publish(Process.whereis(:mqtt), topic, message, 0)

    Logger.info("Published #{message} to #{topic}.")
  end
end
