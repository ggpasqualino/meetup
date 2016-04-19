defmodule MeetupApi.V3.Profile do
  @api_key System.get_env("MEETUP_API_KEY")
  @endpoint "https://api.meetup.com"

  @spec all(String.t) :: Stream.t(map)
  def all(group) do
    group
    |> first_page_url
    |> MeetupApi.V3.Profile.ResultStream.new
  end

  def fetch_page(url) do
    url
    |> HTTPoison.get
    |> handle_response
  end

  @spec one(String.t, String.t, list(String.t)) :: map
  def one(group, member_id, extra_fields \\ ["memberships", "topics"])
  def one(group, member_id, extra_fields) do
    params = %{
      group_urlname: group,
      key: @api_key,
      fields: Enum.join(extra_fields, ",")
    }

    "#{@endpoint}/members/#{member_id}"
    |> HTTPoison.get([], params: params )
    |> handle_response
  end

  defp handle_response({:ok, response}) do
    case response do
      %HTTPoison.Response{status_code: status_code, headers: headers, body: body} when status_code in 200..399 ->
        {:ok, parse_response(headers, body)}
      %HTTPoison.Response{headers: headers, body: body} ->
        {:error, parse_response(headers, body)}
    end
  end

  defp handle_response({:error, response}) do
    {:error, "#{inspect response}"}
  end

  defp parse_response(headers, body) do
    upsert = fn {k, v}, map ->
      Map.update(map, k, [v], &([v | &1]))
    end
    headers = Enum.reduce(headers, Map.new, upsert)
    headers = Map.put(headers, "Link", parse_links(headers))
    %{meta: headers, result: Poison.decode!(body)}
  end

  defp parse_links(%{"Link" => links}) do
    Enum.into(links, Map.new, fn link ->
      [_, link, rel] = Regex.run(~r{<([^>]+)>.*rel="([a-z]+)"}, link)
      {rel, link}
    end)
  end

  def first_page_url(group) do
    params =
      %{
        key: @api_key,
        page: 200,
        offset: 0,
        fields: "memberships,topics"
      }

    "#{@endpoint}/#{group}/members?#{URI.encode_query(params)}"
  end

  defmodule ResultStream do
    alias MeetupApi.V3.Profile

    def new(first_page_url) do
      Stream.resource(
        fn -> first_page_url end,
        &fetch_page/1,
        fn _ -> end)
    end

    def fetch_page(nil) do
      {:halt, nil}
    end

    def fetch_page(url) do
      {:ok, %{meta: meta, result: result}} = Profile.fetch_page(url)
      {result, get_in(meta, ["Link", "next"])}
    end
  end
end
