defmodule Thermio do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Thermio.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Thermio.Endpoint, []),
      # Start your own worker by calling: Thermio.Worker.start_link(arg1, arg2, arg3)
      # worker(Thermio.Worker, [arg1, arg2, arg3]),
      supervisor(Thermio.MqttClient, [%{}])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Thermio.Supervisor]
    {:ok, supervisor_pid} = supervisor = Supervisor.start_link(children, opts)

    {_module, mqtt_pid, _, _} = Supervisor.which_children(supervisor_pid)
    |> List.first

    Process.register(mqtt_pid, :mqtt)
    Thermio.MqttClient.start
    HTTPoison.start
    supervisor
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Thermio.Endpoint.config_change(changed, removed)
    :ok
  end
end
