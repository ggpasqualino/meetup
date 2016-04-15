defmodule MeetupApi.V3.ProfileTest do
  use ExUnit.Case, async: true

  test "get group member with default extra fields" do
    member = MeetupApi.V3.Profile.one("budapest-elixir", "152928012")

    attributes = Map.keys(member)

    assert "id" in attributes
    assert "name" in attributes
    assert "topics" in attributes
    assert "memberships" in attributes
  end
end
