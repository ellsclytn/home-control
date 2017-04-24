defmodule Thermio.Repo.Migrations.CreateClimate do
  use Ecto.Migration

  def change do
    create table(:climates) do
      add :heat_index, :float
      add :humidity, :float
      add :temperature, :float

      timestamps()
    end

  end
end
