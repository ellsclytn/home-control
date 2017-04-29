defmodule Thermio.AirconController do
  use Thermio.Web, :controller

  alias Thermio.Climate

  def store_climate(message) do
    %{
      "temperature" => temperature,
      "humidity" => humidity,
      "heatIndex" => heat_index
    } = Poison.decode!(message)

    changeset = Climate.changeset(%Climate{}, %{
      "temperature" => temperature,
      "humidity" => humidity,
      "heat_index" => heat_index
    })

    case Repo.insert(changeset) do
      {:error, _changeset} ->
        IO.puts("Error inserting climate data")
      _ ->
        nil

    end
  end
end
