defmodule Meetup.Repo.Migrations.CreateMember do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :remote_id, :string
      add :name, :string

      timestamps
    end

  end
end
