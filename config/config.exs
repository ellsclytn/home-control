# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :thermio,
  ecto_repos: [Thermio.Repo]

# Configures the endpoint
config :thermio, Thermio.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: Thermio.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Thermio.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Bus (MQTT Client)
config :bus,
  host: String.to_charlist(System.get_env("MQTT_SERVER")),
  port: String.to_integer(System.get_env("MQTT_PORT")),
  client_id: System.get_env("MQTT_CLIENT_ID"),
  keep_alive: 0,
  username: System.get_env("MQTT_USER"),
  password: System.get_env("MQTT_PASS"),
  auto_reconnect: true,
  auto_connect: true,
  callback: Bus.Callback

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
