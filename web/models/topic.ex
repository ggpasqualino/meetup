defmodule Meetup.Topic do
  use Meetup.Web, :model

  schema "topics" do
    field :remote_id, :string
    field :name, :string
    belongs_to :member, Rumbl.Member

    timestamps
  end

  @required_fields ~w(remote_id name member_id)
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
