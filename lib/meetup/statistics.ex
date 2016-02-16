defmodule Meetup.Statistics do
  @spec topics_histogram(list(map)) :: map
  def topics_histogram(members) do
    members
    |> Enum.flat_map(&Map.get(&1, "topics", []))
    |> Enum.group_by(&(&1["name"]))
    |> Enum.into(%{}, fn {k, v} -> {k, length(v)} end)
  end

  @spec organizers(list(map)) :: map
  def organizers(members) do
    total = length(members)
    organizer_count = Enum.count(members, &is_organizer/1)

    %{"total" => total, "organizer" => organizer_count}
  end

  defp is_organizer(member) do
    not is_nil(get_in(member, ["memberships", "organizer"]))
  end

  @spec groups_histogram(list(map)) :: map
  def groups_histogram(members) do
    members
    |> Enum.flat_map(&join_groups/1)
    |> Enum.group_by(&get_in(&1, ["group", "name"]))
    |> Enum.into(%{}, fn {k, v} -> {k, length(v)} end)
  end

  defp join_groups(member) do
    memberships = Map.get(member, "memberships", %{})
    Map.get(memberships, "organizer", []) ++ Map.get(memberships, "member", [])
  end
end
