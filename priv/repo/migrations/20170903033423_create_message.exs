defmodule Thermio.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :text, :string
      add :origin, :string

      timestamps()
    end

  end
end
