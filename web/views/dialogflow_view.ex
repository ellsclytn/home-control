defmodule Thermio.DialogflowView do
  use Thermio.Web, :view

  defp respond(response) do
    %{speech: response, displayText: response}
  end

  def render("update.json", %{aircon: %{power: 1, mode: 5}}) do
    respond("Bit of a breeze? Got it.")
  end

  def render("update.json", %{aircon: %{power: 1, mode: 4}}) do
    respond("Doing whatever it is the dry mode does.")
  end

  def render("update.json", %{aircon: %{power: 1, mode: mode, temp: temp}}) do
    modes = %{ 
      1 => "setting",
      2 => "heating",
      3 => "cooling"
    }

    respond("Okay, #{modes[mode]} the place at #{temp} degrees.")
  end

  def render("update.json", %{aircon: %{power: 0}}) do
    respond("Shutting off the AC.")
  end
end
