defmodule Thermio.MqttClient do
  require Logger
  use Hulaaki.Client

  def config do
    Application.get_env(:thermio, Thermio.Endpoint)[:mqtt]
  end

  def start do
    options = [
      client_id: "#{config()[:client_id]}-#{:os.system_time(:seconds)}",
      host: config()[:host],
      keep_alive: 0,
      password: config()[:password],
      port: config()[:port],
      username: config()[:username],
      timeout: 5000]

    Thermio.MqttClient.connect(Process.whereis(:mqtt), options)
    subscribe()
  end

  def subscribe do
    queues = Enum.reduce(
      config()[:queues],
      %{:topics => [], :qoses => []},
      fn([topic: topic, qos: qos], %{:topics => topics, :qoses => qoses}) ->
        %{:topics => topics ++ [topic],
          :qoses => qoses ++ [qos]}
      end
    )

    options = [
      id: :rand.uniform(65535),
      topics: queues.topics,
      qoses: queues.qoses]

    Thermio.MqttClient.subscribe(Process.whereis(:mqtt), options)
  end

  def on_connect(_options) do
    Logger.info("Connected to MQTT host #{config()[:host]}")
  end

  def on_disconnect(_options) do
    Logger.info("Disconnected from MQTT host #{config()[:host]}")
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

    Thermio.MqttClient.publish(Process.whereis(:mqtt), options)
    Logger.info("Published #{message} to #{topic} with packet_id #{packet_id}.")
  end

  def on_subscribed_publish(options) do
    option = List.first(options)
    message = elem(option, 1).message
    topic = elem(option, 1).topic

    Logger.info("Message #{message} from #{topic}.")

    case topic do
      "climate" ->
        Thermio.ClimateController.create_from_json(message)
      "soil" ->
        Thermio.SoilController.create_from_string(message)
      _ ->
        Logger.warn("Invalid topic #{topic}")
    end
  end
end
