defmodule Thermio.MqttClientWatcher do
  use GenServer

  defp config do
    Application.get_env(:thermio, Thermio.Endpoint)[:mqtt]
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{}, [])
  end

  def init(state) do
    options = [
      client_id: "#{config()[:client_id]}-#{:os.system_time(:seconds)}",
      host: config()[:host],
      keep_alive: 0,
      password: config()[:password],
      port: config()[:port],
      username: config()[:username],
      timeout: 5000]


    Thermio.MqttClient.start_link(%{}, [name: :mqtt])

    with :ok <- Thermio.MqttClient.connect(Process.whereis(:mqtt), options) do
      subscribe()
      {:ok, state}
    else
      error ->
        Process.sleep(5000)
        error
    end
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
      topics: queues.topics,
      qoses: queues.qoses]

    Thermio.MqttClient.subscribe(:mqtt, options)
  end
end
