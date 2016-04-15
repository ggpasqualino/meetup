defmodule Meetup.GroupBench do
  use Benchfella

  HTTPoison.start

  bench "Sequential requests" do
    detailed_members("budapest-elixir", ["topics"], 16)
  end

  bench "Parallel requests" do
   detailed_members_parallel("budapest-elixir", ["topics"], 16)
  end

  @spec detailed_members(String.t, list(String.t), number) :: map
  def detailed_members(group, fields, page_size) do
    group
    |> MeetupApi.Group.members(page_size)
    |> Enum.map(&Map.get(&1, "member_id"))
    |> Enum.map(&to_string/1)
    |> Enum.map(&MeetupApi.V3.Profile.one(group, &1, fields))
  end

  @spec detailed_members_parallel(String.t, list(String.t), number) :: map
  def detailed_members_parallel(group, fields, page_size) do
    group
    |> MeetupApi.Group.members(page_size)
    |> Enum.map(fn m ->
      member_id = m |> Map.get("member_id") |> to_string
      Task.async(fn -> MeetupApi.V3.Profile.one(group, member_id, fields) end)
    end)
    |> Enum.map(&Task.await/1)
  end
end
