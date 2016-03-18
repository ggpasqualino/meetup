import Ecto
import Ecto.Query

alias Meetup.Repo

defmodule Meetup.Statistics do
  @spec topics_histogram(list(Meetup.Member.t)) :: map
  def topics_histogram(members) do
    topics = assoc(members, :topics)

    count_querry = from t in topics,
      group_by: t.name,
      select: {t.name, count(t.remote_id)}

    count_querry
    |> Repo.all
    |> Enum.into(%{})
  end

  @spec organizers(list(Meetup.Member.t)) :: map
  def organizers(members) do
    members = Enum.uniq(members)
    total = length(members)

    memberships = assoc(members, :memberships)
    organizer_count =
      from m in memberships,
      where: m.organizer == true,
      select: count(m.member_id, :distinct)

     organizer_count = Repo.one(organizer_count)

    %{"total" => total, "organizer" => organizer_count}
  end

  @spec groups_histogram(list(Meetup.Member.t)) :: map
  def groups_histogram(members) do
    memberships = assoc(members, :memberships)

    count_querry = from m in memberships,
      group_by: m.group_name,
      select: {m.group_name, count(m.remote_id)}

    count_querry
    |> Repo.all
    |> Enum.into(%{})
  end
end
