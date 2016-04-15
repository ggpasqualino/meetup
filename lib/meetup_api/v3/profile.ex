defmodule MeetupApi.V3.Profile do
  @api_key System.get_env("MEETUP_API_KEY")
  @member_endpoint "https://api.meetup.com/members/"

  @spec one(String.t, String.t, list(String.t)) :: map
  def one(group, member_id, extra_fields \\ ["memberships", "topics"])
  def one(group, member_id, extra_fields) do
    params = %{
      group_urlname: group,
      key: @api_key,
      fields: Enum.join(extra_fields, ",")
    }

    @member_endpoint
    |> Kernel.<>(member_id)
    |> HTTPoison.get([], params: params )
    |> handle_response
  end

  defp handle_response({:ok, response}) do
    %HTTPoison.Response{status_code: 200, body: body} = response
    Poison.decode!(body)
  end

  defp handle_response({:error, response}) do
    {:error, "#{inspect response}"}
  end
end
