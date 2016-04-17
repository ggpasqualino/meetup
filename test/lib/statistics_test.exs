defmodule Meetup.StatisticsTest do
  use ExUnit.Case, async: true

  test "topics histogram" do
    member1 = %{"topics" => [%{"name" => "topic 1"}, %{"name" => "topic 2"}]}
    member2 = %{"topics" => [%{"name" => "topic 2"}, %{"name" => "topic 3"}]}
    member3 = %{}
    members = [member1, member2, member3]
    statistics = Meetup.Statistics.topics_histogram(members)

    assert statistics["topic 1"] == 1
    assert statistics["topic 2"] == 2
    assert statistics["topic 3"] == 1
  end

  test "organizers" do
    member1 = %{
      "memberships" => %{
      "organizer" => [%{
        "group" => %{"name" => "organizer 1"}
      }],
      "member" => [%{
        "group" => %{"name" => "member"}
      }]
    }}
    member2 = %{
      "memberships" => %{
      "organizer" => [%{
        "group" => %{"name" => "organizer 2"}
      }],
      "member" => [%{
        "group" => %{"name" => "member"}
      }]
    }}
    member3 = %{
      "memberships" => %{
      "organizer" => [],
      "member" => [%{
        "group" => %{"name" => "member"}
      }]
    }}
    members = [member1, member2, member3]
    statistics = Meetup.Statistics.organizers(members)

    assert statistics["total"] == 3
    assert statistics["organizer"] == 2
  end

  test "groups histogram" do
    member1 = %{
      "memberships" => %{
      "organizer" => [%{
        "group" => %{"name" => "organizer 1"}
      }],
      "member" => [%{
        "group" => %{"name" => "member"}
      }]
    }}
    member2 = %{
      "memberships" => %{
      "organizer" => [%{
        "group" => %{"name" => "organizer 2"}
      }],
      "member" => [%{
        "group" => %{"name" => "member"}
      }]
    }}
    member3 = %{
      "memberships" => %{
      "member" => [%{
        "group" => %{"name" => "member"}
      }]
    }}
    members = [member1, member2, member3]
    statistics = Meetup.Statistics.groups_histogram(members)

    assert statistics["organizer 1"] == 1
    assert statistics["organizer 2"] == 1
    assert statistics["member"] == 3
  end
end
