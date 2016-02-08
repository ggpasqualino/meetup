defmodule Meetup.MembersTest do
  use ExUnit.Case, async: true

  test "get members" do
    response = Meetup.Members.get

    IO.inspect response

    assert is_list(response)
    assert length(response) == 20

  end

end
