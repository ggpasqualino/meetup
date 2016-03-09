defmodule Meetup.Repo.Migrations.CreateMembership do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :remote_id, :string
      add :group_name, :string
      add :organizer, :boolean, default: false
      add :member_id, references(:members)

      timestamps
    end

  end
end
