defmodule Thermio.Aircon do
  use Thermio.Web, :model

  schema "aircons" do
    field :power, :integer
    field :mode, :integer
    field :fan, :integer
    field :temp, :integer
    field :v_dir, :integer
    field :h_dir, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:power, :mode, :fan, :temp, :v_dir, :h_dir])
    |> validate_required([:power, :mode, :fan, :temp, :v_dir, :h_dir])
  end
end
