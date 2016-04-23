defmodule MeetupApi.V3.ResultStream do
  alias MeetupApi.V3.Api

  @spec new(String.t) :: Stream.t
  @spec new(String.t, (String.t -> {:ok, map})) :: Stream.t
  def new(first_page_url, fetcher \\ &Api.get/1) do
    Stream.resource(
      fn -> {first_page_url, fetcher} end,
      &fetch_page/1,
      fn _ -> true end)
  end

  defp fetch_page({nil, _fetcher}) do
    {:halt, nil}
  end

  defp fetch_page({url, fetcher}) do
    {:ok, %{meta: meta, result: result}} = fetcher.(url)

    {result, {get_in(meta, ["Link", "next"]), fetcher}}
  end
end
