defmodule Thermio.AirconTest do
  use Thermio.ModelCase

  alias Thermio.Aircon

  @valid_attrs %{fan: 42, h_dir: 42, mode: 42, power: 42, temp: 42, v_dir: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Aircon.changeset(%Aircon{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Aircon.changeset(%Aircon{}, @invalid_attrs)
    refute changeset.valid?
  end
end
