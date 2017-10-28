defmodule Thermio.MqttClient do
  require Logger
  use Hulaaki.Client

  defp config do
    Application.get_env(:thermio, Thermio.Endpoint)[:mqtt]
  end

  def publish_message(topic, message) do
    packet_id = :rand.uniform(65535)
    options = [
      id: packet_id,
      topic: topic,
      message: message,
      dup: 0,
      qos: 0,
      retain: 0]

    Thermio.MqttClient.publish(:mqtt, options)
    Logger.info("Published #{message} to #{topic} with packet_id #{packet_id}.")
  end

  def on_connect(_options) do
    Logger.info("Connected to MQTT host #{config()[:host]}")
  end

  def on_disconnect(_options) do
    Logger.info("Disconnected from MQTT host #{config()[:host]}")
  end

  def on_subscribed_publish(message: %{ message: body, topic: topic }, state: _state) do
    Logger.info("Message #{body} from #{topic}.")

    case topic do
      "climate" ->
        Thermio.ClimateController.create_from_json(body)
      _ ->
        Logger.warn("Invalid topic #{topic}")
    end
  end
end
