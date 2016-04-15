defmodule MeetupApi.GroupTest do
  use ExUnit.Case, async: true

  test "get members with default page size" do
    members = MeetupApi.Group.members("budapest-elixir")

    assert is_list(members)
    assert length(members) == 20
  end

  test "get members with page size" do
    members = MeetupApi.Group.members("budapest-elixir", _page_size = 30)

    assert is_list(members)
    assert length(members) == 30
  end

  test "member has basic attributes" do
    [member] = MeetupApi.Group.members("budapest-elixir", _page_size = 1)

    attributes = Map.keys(member)

    assert "group" in attributes
    assert "member_id" in attributes
    assert "name" in attributes
  end
end
