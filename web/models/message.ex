defmodule Thermio.Message do
  use Thermio.Web, :model

  schema "messages" do
    field :text, :string
    field :origin, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text, :origin])
    |> validate_required([:text, :origin])
  end
end
