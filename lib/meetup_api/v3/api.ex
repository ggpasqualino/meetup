defmodule MeetupApi.V3.Api do
  alias MeetupApi.V3.Request

  @endpoint "https://api.meetup.com"

  def endpoint, do: @endpoint

  def get(request, getter \\ &HTTPoison.get/1)
  def get(%Request{} = request, getter) do
    request.user
    |> MeetupApi.Cache.server_process
    |> MeetupApi.Server.do_request(fn ->
      request
      |> build_url
      |> getter.()
      |> handle_response
    end)
  end

  def build_url(%Request{path: path, params: %Request.Params{} = params}) do
    parsed_params =
      params
      |> Map.from_struct
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Enum.into(%{})
      |> URI.encode_query

    "#{endpoint()}#{path}?#{parsed_params}"
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
