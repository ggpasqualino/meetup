defmodule Meetup.MembershipTest do
  use Meetup.ModelCase

  alias Meetup.Membership

  @valid_attrs %{group_name: "some content", organizer: true, remote_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Membership.changeset(%Membership{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Membership.changeset(%Membership{}, @invalid_attrs)
    refute changeset.valid?
  end
end
