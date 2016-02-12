defmodule Meetup.GroupTest do
  use ExUnit.Case, async: true

  test "get members with default page size" do
    response = Meetup.Group.members("budapest-elixir")

    assert is_list(response)
    assert length(response) == 20
  end

  test "get members with page size" do
    response = Meetup.Group.members("budapest-elixir", _page = 30)

    assert is_list(response)
    assert length(response) == 30
  end

  test "member has basic attributes" do
    [member] = Meetup.Group.members("budapest-elixir", _page = 1)

    attributes = Map.keys(member)

    assert "group" in attributes
    assert "member_id" in attributes
    assert "name" in attributes
  end
end
