defmodule Meetup.Statistics do
  def topics_histogram(members) do
    members
    |> Enum.flat_map(&(&1["topics"]))
    |> Enum.group_by(&(&1["name"]))
    |> Enum.into(%{}, fn {k, v} -> {k, length(v)} end)
  end
end
