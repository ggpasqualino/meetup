defmodule Meetup.Membership do
  use Meetup.Web, :model

  schema "memberships" do
    field :remote_id, :string
    field :group_name, :string
    field :organizer, :boolean, default: false
    belongs_to :member, Meetup.Member

    timestamps
  end

  @required_fields ~w(remote_id group_name organizer member_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
