defmodule Mix.Tasks.Meetup.Import do
  use Mix.Task

  import Ecto.Query

  alias Meetup.Repo
  alias Meetup.Member
  alias Meetup.Topic
  alias Meetup.Membership

  @shortdoc "Import members from meetup.com to the database"

  def run([group_urlname, amount]) do
    HTTPoison.start
    Repo.start_link

    Mix.shell.info "Importing #{amount} members from #{group_urlname} group from meetup.com"

    existing_members = Repo.all(from m in Member, select: m.remote_id)

    Mix.shell.info "Existing members #{inspect existing_members}"

    member_ids =
      group_urlname
      |> Meetup.Group.members(amount)
      |> Enum.map(fn m -> to_string(m["member_id"]) end)
      |> Kernel.--(existing_members)

    Mix.shell.info "members to import: #{inspect member_ids}"

    members = Enum.map(member_ids, &insert_member(&1, group_urlname))
  end

  defp insert_member(member_id, group_urlname) do
    Mix.shell.info "Importing member: #{member_id}"

    m = Meetup.Group.member(group_urlname, member_id)
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
