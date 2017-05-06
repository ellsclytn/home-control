defmodule Thermio.SoilTest do
  use Thermio.ModelCase

  alias Thermio.Soil

  @valid_attrs %{moisture: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Soil.changeset(%Soil{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Soil.changeset(%Soil{}, @invalid_attrs)
    refute changeset.valid?
  end
end
