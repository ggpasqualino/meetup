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

    organizer_count = Enum.count(members, &is_organizer/1)

    %{"total" => total, "organizer" => organizer_count}
  end

  defp is_organizer(member) do
    memberships = assoc(member, :memberships)

    organizer_memberships = from memberships, where: [organizer: true]

    organizer_memberships
    |> Repo.all
    |> Enum.empty?
    |> Kernel.not
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
