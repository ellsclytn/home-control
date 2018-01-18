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

  def set_aircon(params) do
    aircon =
      Thermio.Aircon
      |> order_by(desc: :inserted_at)
      |> limit(1)
      |> Thermio.Repo.one
      |> Kernel.||(%{
        power: 0,
        mode: 3,
        fan: 0,
        temp: 24,
        v_dir: 0,
        h_dir: 0
      })

    intitial_state = %{
      "power" => aircon.power,
      "mode" => aircon.mode,
      "fan" => aircon.fan,
      "temp" => aircon.temp,
      "v_dir" => aircon.v_dir,
      "h_dir" => aircon.h_dir
    }

    changeset_params =
      intitial_state
      |> Map.merge(params)

    changeset = Aircon.changeset(%Aircon{}, changeset_params)


    mqtt_payload =
      changeset_params
      |> Map.merge(%{"type" => "set"})
      |> ProperCase.to_camel_case
      |> Poison.encode!

    Thermio.MqttClient.publish_message("heatpump", mqtt_payload)

    Repo.insert(changeset)
  end

  def handle_dialogflow(conn, %{"result" => %{"action" => "input.welcome"}}) do
    %{heat_index: heat_index} =
      Thermio.Climate
      |> order_by(desc: :inserted_at)
      |> limit(1)
      |> Thermio.Repo.one

    aircon =
      Thermio.Aircon
      |> order_by(desc: :inserted_at)
      |> limit(1)
      |> Thermio.Repo.one

    conn
    |> put_status(:ok)
    |> render(Thermio.DialogflowView, "summary.json", %{aircon: aircon, heat_index: heat_index})
  end

  def handle_dialogflow(conn, %{"result" => %{"action" => "ac.setting", "parameters" => %{
    "mode" => mode,
    "temp" => power,
    "power" => temp
  }}}) do
    modes = %{
      "auto" => 1,
      "heat" => 2,
      "cool" => 3,
      "dry" => 4,
      "fan" => 5
    }

    powers = %{
      "on" => 1,
      "off" => 0
    }

    temp = if (temp == "" || !temp), do: 24, else: temp

    params = %{
      "mode" => modes[mode] || 3,
      "power" => powers[power] || 1,
      "temp" => temp
    }

    case set_aircon(params) do
      {:ok, aircon} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", aircon_path(conn, :show, aircon))
        |> render(Thermio.DialogflowView, "update.json", aircon: aircon)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Thermio.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def create(conn, params) do
    case set_aircon(params) do
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
