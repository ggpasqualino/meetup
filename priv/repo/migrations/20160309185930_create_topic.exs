defmodule Meetup.Repo.Migrations.CreateTopic do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :remote_id, :string
      add :name, :string
      add :member_id, references(:members)

      timestamps
    end

  end
end
