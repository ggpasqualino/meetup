defmodule MeetupApi.V3.ResultStream do
  alias MeetupApi.V3.Profile

  @spec new(String.t) :: Stream.t
  def new(first_page_url) do
    Stream.resource(
      fn -> first_page_url end,
      &fetch_page/1,
      fn _ -> true end)
  end

  defp fetch_page(nil) do
    {:halt, nil}
  end

  defp fetch_page(url) do
    {:ok, %{meta: meta, result: result}} = Profile.get(url)

    {result, get_in(meta, ["Link", "next"])}
  end
end
