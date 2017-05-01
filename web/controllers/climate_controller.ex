defmodule Thermio.ClimateController do
  require Logger
  use Thermio.Web, :controller
  use Timex

  alias Thermio.Climate

  def index(conn, _params) do
    climates =
      Thermio.Climate
      |> where([c], c.inserted_at >= ^Timex.shift(Timex.now(), days: -1))
      |> order_by(desc: :inserted_at)
      |> Thermio.Repo.all

    render(conn, "index.json", climates: climates)
  end

  defp parse_date(str, tz) do
    Timex.parse!(str, "{YYYY}-{0M}-{0D}")
    |> Timex.to_datetime(tz)
  end

  defp query_by_date_range(start_time, end_time) do
    Thermio.Climate
    |> where([c], c.inserted_at >= ^start_time)
    |> where([c], c.inserted_at < ^end_time)
    |> order_by(desc: :inserted_at)
    |> Thermio.Repo.all
  end

  def index_by_date(conn, %{"date" => date_str} = params) do
    tz = Map.get(params, "tz", System.get_env("TIMEZONE"))
    start_time = parse_date(date_str, tz)
    end_time = Timex.shift(start_time, days: 1)

    climates = query_by_date_range(start_time, end_time)
    render(conn, "index.json", climates: climates)
  end

  def index_by_dates(conn, %{"start_date" => start_date_str, "end_date" => end_date_str} = params) do
    tz = Map.get(params, "tz", System.get_env("TIMEZONE"))
    start_time = parse_date(start_date_str, tz)
    end_time =
      parse_date(end_date_str, tz)
      |> Timex.shift(days: 1)

    climates = query_by_date_range(start_time, end_time)
    render(conn, "index.json", climates: climates)
  end

  defp create_changeset(climate_params) do
    changeset = Climate.changeset(%Climate{}, climate_params)

    if length(changeset.errors) > 0 do
      {:error, "Validation required"}
    else
      {:ok, changeset}
    end
  end

  def create_from_json(message) do
    with {:ok, json} <- Poison.decode(message),
      snake_case <- ProperCase.to_snake_case(json),
      {:ok, changeset} <- create_changeset(snake_case),
      {:ok, %{id: id}} <- Repo.insert(changeset)
    do
      Logger.info("Climate #{id} created")
    else
      {:error, error} -> Logger.error(error)
    end
  end

  def show(conn, %{"id" => id}) do
    climate = Repo.get!(Climate, id)
    render(conn, "show.json", climate: climate)
  end

  def update(conn, %{"id" => id, "climate" => climate_params}) do
    climate = Repo.get!(Climate, id)
    changeset = Climate.changeset(climate, climate_params)

    case Repo.update(changeset) do
      {:ok, climate} ->
        render(conn, "show.json", climate: climate)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Thermio.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    climate = Repo.get!(Climate, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(climate)

    send_resp(conn, :no_content, "")
  end
end
