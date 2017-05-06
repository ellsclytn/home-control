defmodule Thermio.SoilController do
  require Logger
  use Thermio.Web, :controller
  use Timex

  alias Thermio.Soil

  def index(conn, _params) do
    soils =
      Thermio.Soil
      |> where([c], c.inserted_at >= ^Timex.shift(Timex.now(), days: -1))
      |> order_by(desc: :inserted_at)
      |> Thermio.Repo.all
    render(conn, "index.json", soils: soils)
  end

  def create_from_string(message) do
    changeset = Soil.changeset(%Soil{}, %{"moisture" => String.to_integer(message)})

    case Repo.insert(changeset) do
      {:ok, soil} ->
        Logger.info("Soil #{soil.id} created")
      {:error, changeset} ->
        Logger.error(changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    soil = Repo.get!(Soil, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(soil)

    send_resp(conn, :no_content, "")
  end
end
