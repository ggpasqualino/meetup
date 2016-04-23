defmodule MeetupApi.V3.Api do
  @api_key System.get_env("MEETUP_API_KEY")
  @endpoint "https://api.meetup.com"

  def key, do: @api_key

  def endpoint, do: @endpoint

  def get(url, request \\ &HTTPoison.get/1)  do
    url
    |> request.()
    |> handle_response
  end

  def build_url(path, params) do
    "#{endpoint}#{path}?#{URI.encode_query(params)}"
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

  defp parse_links(_) do
    %{}
  end
end
