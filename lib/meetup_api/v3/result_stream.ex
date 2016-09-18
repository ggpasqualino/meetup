defmodule MeetupApi.V3.ResultStream do
  alias MeetupApi.V3.{Api, Request}

  @spec new(Request.t) :: Stream.t
  @spec new(Request.t, (Request.t -> {:ok, map})) :: Stream.t
  def new(first_page_request, fetcher \\ &Api.get/1) do
    Stream.resource(
      fn -> {first_page_request, fetcher} end,
      &fetch_page/1,
      fn _ -> true end)
  end

  defp fetch_page({nil, _fetcher}) do
    {:halt, nil}
  end

  defp fetch_page({request, fetcher}) do
    {:ok, %{meta: meta, result: result}} = fetcher.(request)

    next_page = Request.parse(get_in(meta, ["Link", "next"]))

    {result, {next_page, fetcher}}
  end
end
