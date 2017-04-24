defmodule Thermio.ClimateTest do
  use Thermio.ModelCase

  alias Thermio.Climate

  @valid_attrs %{heat_index: "120.5", humidity: "120.5", temperature: "120.5"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Climate.changeset(%Climate{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Climate.changeset(%Climate{}, @invalid_attrs)
    refute changeset.valid?
  end
end
