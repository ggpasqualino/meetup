defmodule Meetup.TopicTest do
  use Meetup.ModelCase

  alias Meetup.Topic

  @valid_attrs %{name: "some content", remote_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Topic.changeset(%Topic{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Topic.changeset(%Topic{}, @invalid_attrs)
    refute changeset.valid?
  end
end
