defmodule MeetupApi.V3.ProfileTest do
  use ExUnit.Case, async: true

  # All tests will ping the twitter API
  @moduletag :meetup_api

  test "get group member with default extra fields" do
    {:ok, %{result: member}} = MeetupApi.V3.Profile.one("152928012")

    attributes = Map.keys(member)

    assert "id" in attributes
    assert "name" in attributes
    assert "topics" in attributes
    assert "memberships" in attributes
  end

  test "get all members" do
    members_stream = MeetupApi.V3.Profile.all("budapest-elixir")

    assert Enum.count(members_stream) == 98
  end

  test "member has basic attributes" do
    members_stream = MeetupApi.V3.Profile.all("budapest-elixir")
    [member] = members_stream |> Stream.take(1) |> Enum.to_list
    attributes = Map.keys(member)

    assert "group_profile" in attributes
    assert "id" in attributes
    assert "name" in attributes
    assert "memberships" in attributes
    assert "topics" in attributes
  end
end
