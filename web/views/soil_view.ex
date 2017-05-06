defmodule Thermio.SoilView do
  use Thermio.Web, :view

  def render("index.json", %{soils: soils}) do
    %{data: render_many(soils, Thermio.SoilView, "soil.json")}
  end

  def render("show.json", %{soil: soil}) do
    %{data: render_one(soil, Thermio.SoilView, "soil.json")}
  end

  def render("soil.json", %{soil: soil}) do
    %{id: soil.id,
      moisture: soil.moisture,
      time: soil.inserted_at}
  end
end
