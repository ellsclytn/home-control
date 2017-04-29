defmodule Thermio.AirconView do
  use Thermio.Web, :view

  def render("index.json", %{aircons: aircons}) do
    %{data: render_many(aircons, Thermio.AirconView, "aircon.json")}
  end

  def render("show.json", %{aircon: aircon}) do
    %{data: render_one(aircon, Thermio.AirconView, "aircon.json")}
  end

  def render("aircon.json", %{aircon: aircon}) do
    %{id: aircon.id,
      power: aircon.power,
      mode: aircon.mode,
      fan: aircon.fan,
      temp: aircon.temp,
      v_dir: aircon.v_dir,
      h_dir: aircon.h_dir}
  end
end
