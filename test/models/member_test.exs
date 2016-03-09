defmodule Meetup.MemberTest do
  use Meetup.ModelCase

  alias Meetup.Member

  @valid_attrs %{name: "some content", remote_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Member.changeset(%Member{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Member.changeset(%Member{}, @invalid_attrs)
    refute changeset.valid?
  end
end
