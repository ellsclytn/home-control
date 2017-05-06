defmodule Thermio.Repo.Migrations.CreateSoil do
  use Ecto.Migration

  def change do
    create table(:soils) do
      add :moisture, :integer

      timestamps()
    end

  end
end
