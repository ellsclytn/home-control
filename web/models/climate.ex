defmodule Thermio.Climate do
  use Thermio.Web, :model

  schema "climates" do
    field :heat_index, :float
    field :humidity, :float
    field :temperature, :float

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:heat_index, :humidity, :temperature])
    |> validate_required([:heat_index, :humidity, :temperature])
  end
end
