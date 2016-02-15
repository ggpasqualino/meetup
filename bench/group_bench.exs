defmodule Meetup.GroupBench do
  use Benchfella

  HTTPoison.start

  bench "Sequential requests" do
    Meetup.Group.detailed_members("budapest-elixir", ["topics"], 10)
  end

  # 2.3063, 3.5651, 3.882 times faster
  bench "Parallel requests" do
    Meetup.Group.detailed_members_parallel("budapest-elixir", ["topics"], 10)
  end
end
