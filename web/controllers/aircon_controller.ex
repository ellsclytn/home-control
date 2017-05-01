defmodule Thermio.AirconController do
  use Thermio.Web, :controller

  alias Thermio.Aircon

  def index(conn, _params) do
    aircon =
      Thermio.Aircon
      |> order_by(desc: :inserted_at)
      |> limit(1)
      |> Thermio.Repo.one

    render(conn, "show.json", aircon: aircon)
  end

  def create(conn, aircon_params) do
    changeset = Aircon.changeset(%Aircon{}, aircon_params)

    mqtt_payload = aircon_params
    |> Map.merge(%{"type" => "set"})
    |> ProperCase.to_camel_case
    |> Poison.encode!

    Thermio.MqttClient.publish_message("heatpump", mqtt_payload)

    case Repo.insert(changeset) do
      {:ok, aircon} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", aircon_path(conn, :show, aircon))
        |> render("show.json", aircon: aircon)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Thermio.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    aircon = Repo.get!(Aircon, id)
    render(conn, "show.json", aircon: aircon)
  end

  def update(conn, %{"id" => id, "aircon" => aircon_params}) do
    aircon = Repo.get!(Aircon, id)
    changeset = Aircon.changeset(aircon, aircon_params)

    case Repo.update(changeset) do
      {:ok, aircon} ->
        render(conn, "show.json", aircon: aircon)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Thermio.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    aircon = Repo.get!(Aircon, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(aircon)

    send_resp(conn, :no_content, "")
  end
end
