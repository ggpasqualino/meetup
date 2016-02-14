defmodule Meetup.StatisticsTest do
  use ExUnit.Case, async: true

  test "topics histogram" do
    member1 = %{"topics" => [%{"name" => "topic 1"}, %{"name" => "topic 2"}]}
    member2 = %{"topics" => [%{"name" => "topic 2"}, %{"name" => "topic 3"}]}
    members = [member1, member2]
    statistics = Meetup.Statistics.topics_histogram(members)

    assert statistics["topic 1"] == 1
    assert statistics["topic 2"] == 2
    assert statistics["topic 3"] == 1
  end
end
