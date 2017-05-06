defmodule Thermio.Soil do
  use Thermio.Web, :model

  schema "soils" do
    field :moisture, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:moisture])
    |> validate_required([:moisture])
  end
end
