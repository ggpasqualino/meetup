defmodule Meetup.Group do
  @api_key System.get_env("MEETUP_API_KEY")
  @group_members_endpoint "https://api.meetup.com/2/profiles"
  @member_endpoint "https://api.meetup.com/members/"

  @spec detailed_members(String.t, list(String.t), number) :: map
  def detailed_members(group, fields, page_size) do
    group
    |> members(page_size)
    |> Enum.map(&Map.get(&1, "member_id"))
    |> Enum.map(&to_string/1)
    |> Enum.map(&member(group, &1, fields))
  end

  @spec members(String.t, number) :: list(map)
  def members(group, page_size \\ 20)
  def members(group, page_size) do
    params = %{
      group_urlname: group,
      key: @api_key,
      sign: true,
      page: page_size
    }

    @group_members_endpoint
    |> HTTPoison.get([], params: params )
    |> handle_response
    |> Map.get("results")
  end

  @spec member(String.t, String.t, list(String.t)) :: map
  def member(group, member_id, extra_fields \\ ["memberships", "topics"])
  def member(group, member_id, extra_fields) do
    params = %{
      group_urlname: group,
      key: @api_key,
      sign: true,
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
