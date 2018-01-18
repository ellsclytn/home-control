defmodule Thermio.DialogflowView do
  use Thermio.Web, :view

  def render("update.json", %{aircon: %{power: 1, mode: mode, temp: temp}}) do
    modes = %{ 
      1 => "setting",
      2 => "heating",
      3 => "cooling",
      4 => "drying",
      5 => "fanning"
    }

    response = "Okay, #{modes[mode]} the place at #{temp} degrees."

    %{speech: response, displayText: response}
  end

  def render("update.json", %{aircon: %{power: 0}}) do
    response = "Shutting off the AC."

    %{speech: response, displayText: response}
  end
end
