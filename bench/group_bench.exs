defmodule Meetup.GroupBench do
  use Benchfella

  HTTPoison.start

  bench "Sequential requests" do
    Meetup.Group.detailed_members("budapest-elixir", ["topics"], 16)
  end

  bench "Parallel requests" do
    Meetup.Group.detailed_members_parallel("budapest-elixir", ["topics"], 16)
  end
end
