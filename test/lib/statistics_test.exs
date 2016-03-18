defmodule Meetup.StatisticsTest do
  use ExUnit.Case, async: true

  alias Meetup.Topic
  alias Meetup.Member
  alias Meetup.Repo

  setup do
    member1 = Repo.insert!(%Member{name: "member 1", remote_id: "1"})
    member2 = Repo.insert!(%Member{name: "member 2", remote_id: "2"})
    member3 = Repo.insert!(%Member{name: "member 3", remote_id: "3"})
    {:ok, [member1: member1, member2: member2, member3: member3]}
  end

  test "topics histogram", %{member1: member1, member2: member2, member3: member3} do
    Repo.insert!(%Topic{name: "topic 1", remote_id: "1", member_id: member1.id})
    Repo.insert!(%Topic{name: "topic 2", remote_id: "2", member_id: member1.id})
    Repo.insert!(%Topic{name: "topic 2", remote_id: "2", member_id: member2.id})
    Repo.insert!(%Topic{name: "topic 3", remote_id: "3", member_id: member2.id})

    members = [member1, member2, member3]
    statistics = Meetup.Statistics.topics_histogram(members)

    assert statistics["topic 1"] == 1
    assert statistics["topic 2"] == 2
    assert statistics["topic 3"] == 1
  end

  test "organizers", %{member1: member1, member2: member2, member3: member3} do
    Repo.insert!(%Meetup.Membership{group_name: "member", remote_id: "1", organizer: false, member_id: member1.id})
    Repo.insert!(%Meetup.Membership{group_name: "member", remote_id: "1", organizer: false, member_id: member2.id})
    Repo.insert!(%Meetup.Membership{group_name: "member", remote_id: "1", organizer: false, member_id: member3.id})
    Repo.insert!(%Meetup.Membership{group_name: "organizer 1", remote_id: "2", organizer: true, member_id: member1.id})
    Repo.insert!(%Meetup.Membership{group_name: "organizer 2", remote_id: "3", organizer: true, member_id: member2.id})

    members = [member1, member2, member3]
    statistics = Meetup.Statistics.organizers(members)

    assert statistics["total"] == 3
    assert statistics["organizer"] == 2
  end

  test "groups histogram", %{member1: member1, member2: member2, member3: member3} do
    Repo.insert!(%Meetup.Membership{group_name: "member", remote_id: "1", organizer: false, member_id: member1.id})
    Repo.insert!(%Meetup.Membership{group_name: "member", remote_id: "1", organizer: false, member_id: member2.id})
    Repo.insert!(%Meetup.Membership{group_name: "member", remote_id: "1", organizer: false, member_id: member3.id})
    Repo.insert!(%Meetup.Membership{group_name: "organizer 1", remote_id: "2", organizer: true, member_id: member1.id})
    Repo.insert!(%Meetup.Membership{group_name: "organizer 2", remote_id: "3", organizer: true, member_id: member2.id})

    members = [member1, member2, member3]
    statistics = Meetup.Statistics.groups_histogram(members)

    assert statistics["organizer 1"] == 1
    assert statistics["organizer 2"] == 1
    assert statistics["member"] == 3
  end
end
