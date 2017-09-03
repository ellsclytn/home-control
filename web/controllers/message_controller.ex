defmodule Thermio.MessageController do
  use Thermio.Web, :controller

  alias Thermio.Message

  plug :telegram_user

  defp telegram_user(conn, _opts) do
    %{params: %{"message" => %{"chat" => %{"id" => chat_id}}}} = conn

    if (to_string(chat_id) === System.get_env("TELEGRAM_CHAT_ID")) do
      conn
    else
      conn
      |> send_resp(401, "")
      |> halt
    end
  end

  defp send_telegram_message(message) do
    HTTPoison.post!(
      "https://api.telegram.org/bot#{System.get_env("TELEGRAM_TOKEN")}/sendMessage",
      Poison.encode!(%{
        "chat_id" => String.to_integer(System.get_env("TELEGRAM_CHAT_ID")),
        "text" => message
      }),
      [{"Content-Type", "application/json"}]
    )
  end

  defp set_ac(text) do

    turning_off = ~r/(aircon off)/iu
    setting_temperature = ~r/(aircon )(\d+)/iu
    analysis =
      cond do
        String.match?(text, setting_temperature) ->
          [_, _, temperature] = Regex.run(~r/(aircon )(\d+)/iu, text)
          %{
            "message" => "Setting the AC to #{temperature}.",
            "settings" => %{
              "temp" => String.to_integer(temperature),
              "power" => 1
            }
          }
        String.match?(text, turning_off) ->
          %{
            "message" => "Turning off the AC",
            "settings" => %{
              "power" => 0
            }
          }
        true -> nil
      end

    if (analysis) do
      Thermio.AirconController.set_aircon(analysis["settings"])
      send_telegram_message(analysis["message"])
    end

  end

  def create(conn, %{"message" => %{
    "text" => text
  }}) do
    changeset = Message.changeset(%Message{}, %{
      "text" => text,
      "origin" => "telegram"
    })

    case Repo.insert(changeset) do
      {:ok, _} -> :noop
      {:error, _} ->
        IO.warn("Failed to save message to database.")
    end

    cond do
      String.match?(text, ~r/(aircon )/iu) -> set_ac(text)
      true -> IO.puts("No relevant operation.")
    end

    send_resp(conn, :ok, "")
  end

  def show(conn, %{"id" => id}) do
    message = Repo.get!(Message, id)
    render(conn, "show.json", message: message)
  end
end
