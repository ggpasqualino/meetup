defmodule MeetupApi.V3.Profile do
  @api_key System.get_env("MEETUP_API_KEY")
  @endpoint "https://api.meetup.com/"

  @spec all(String.t, number, list(String.t)) :: list(map)
  def all(group, page_size \\ 20, extra_fields \\ ["memberships", "topics"])
  def all(group, page_size, extra_fields) do
    params = %{
      group_urlname: group,
      key: @api_key,
      page: page_size,
      fields: Enum.join(extra_fields, ",")
    }

    "#{@endpoint}/#{group}/members"
    |> HTTPoison.get([], params: params )
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
      %HTTPoison.Response{status_code: status_code, body: body} when status_code in 200..399 ->
        {:ok, Poison.decode!(body)}
      %HTTPoison.Response{ body: body} ->
        {:error, Poison.decode!(body)}
    end
  end

  defp handle_response({:error, response}) do
    {:error, "#{inspect response}"}
  end
end
