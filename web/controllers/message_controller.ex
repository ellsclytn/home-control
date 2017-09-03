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

  def create(conn, %{"message" => %{
    "text" => text,
    "chat" => %{ "id" => chat_id }
  }}) do
    HTTPoison.post!(
      "https://api.telegram.org/bot#{System.get_env("TELEGRAM_TOKEN")}/sendMessage",
      Poison.encode!(%{
        "chat_id" => chat_id,
        "text" => "Message \"#{text}\" received."
      }),
      [{"Content-Type", "application/json"}]
    )

    changeset = Message.changeset(%Message{}, %{
      "text" => text,
      "origin" => "telegram"
    })

    case Repo.insert(changeset) do
      {:ok, _} ->
        send_resp(conn, :ok, "")
      {:error, _} ->
        IO.warn("Failed to save message to database.")
    end
  end

  def show(conn, %{"id" => id}) do
    message = Repo.get!(Message, id)
    render(conn, "show.json", message: message)
  end
end
