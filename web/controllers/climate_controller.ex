defmodule Thermio.ClimateController do
  use Thermio.Web, :controller

  alias Thermio.Climate

  def index(conn, _params) do
    climates = Repo.all(Climate)
    render(conn, "index.json", climates: climates)
  end

  def create(conn, %{"climate" => climate_params}) do
    changeset = Climate.changeset(%Climate{}, climate_params)

    case Repo.insert(changeset) do
      {:ok, climate} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", climate_path(conn, :show, climate))
        |> render("show.json", climate: climate)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Thermio.ChangesetView, "error.json", changeset: changeset)
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
