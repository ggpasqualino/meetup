defmodule Mix.Tasks.Meetup.Import do
  use Mix.Task

  alias Meetup.Repo
  alias Meetup.Member
  alias Meetup.Topic
  alias Meetup.Membership

  @shortdoc "Import members from meetup.com to the database"

  def run([group_urlname, amount]) do
    HTTPoison.start
    Repo.start_link

    Mix.shell.info "Importing #{amount} members from #{group_urlname} group from meetup.com"

    members = Meetup.Group.detailed_members_parallel(group_urlname, ["memberships", "topics"], amount)

    members = Enum.map(members, &insert_member(&1))

    IO.inspect members
  end

  defp insert_member(m) do
    member = Repo.insert!(%Member{name: m["name"], remote_id: to_string(m["id"])})
    insert_organized_meetups(member, m)
    insert_member_meetups(member, m)
    insert_topics(member, m)

    member
  end

  defp insert_organized_meetups(member, remote_member) do
    (get_in(remote_member, ["memberships", "organizer"]) || [])
    |> Enum.map(fn g ->
      %Membership{group_name: get_in(g, ["group", "name"]),
                  remote_id: to_string(get_in(g, ["group", "id"])),
                  organizer: true,
                  member_id: member.id}
    end)
    |> Enum.map(&Repo.insert!(&1))
  end

  defp insert_member_meetups(member, remote_member) do
    (get_in(remote_member, ["memberships", "member"]) || [])
    |> Enum.map(fn g ->
      %Membership{group_name: get_in(g, ["group", "name"]),
                  remote_id: to_string(get_in(g, ["group", "id"])),
                  organizer: false,
                  member_id: member.id}
    end)
    |> Enum.map(&Repo.insert!(&1))
  end

  defp insert_topics(member, remote_member) do
    (get_in(remote_member, ["topics"]) || [])
    |> Enum.map(fn t -> %Topic{name: t["name"], remote_id: to_string(t["id"]), member_id: member.id} end)
    |> Enum.map(&Repo.insert!(&1))
  end
end
