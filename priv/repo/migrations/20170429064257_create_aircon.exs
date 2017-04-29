defmodule Thermio.Repo.Migrations.CreateAircon do
  use Ecto.Migration

  def change do
    create table(:aircons) do
      add :power, :integer
      add :mode, :integer
      add :fan, :integer
      add :temp, :integer
      add :v_dir, :integer
      add :h_dir, :integer

      timestamps()
    end

  end
end
