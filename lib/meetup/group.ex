defmodule Meetup.Group do
  @api_key System.get_env("MEETUP_API_KEY")
  @group_members_endpoint "https://api.meetup.com/2/profiles"
  @member_endpoint "https://api.meetup.com/members/"

  def members(group, page \\ 20)
  def members(group, page) do
    params = %{
      group_urlname: group,
      key: @api_key,
      sign: true,
      page: page
    }

    @group_members_endpoint
    |> HTTPoison.get([], params: params )
    |> handle_response
    |> Map.get("results")
  end

  def member(group, member_id, extra_fields \\ ["memberships", "topics"])
  def member(group, member_id, extra_fields) do
    params = %{
      group_urlname: group,
      key: @api_key,
      sign: true,
      fields: Enum.join(extra_fields, ",")
    }

    @member_endpoint <> member_id
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
