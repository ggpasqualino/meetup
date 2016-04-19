defmodule MeetupApi.Group do
  @api_key System.get_env("MEETUP_API_KEY")
  @group_members_endpoint "https://api.meetup.com/2/profiles"

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

  defp handle_response({:ok, response}) do
    %HTTPoison.Response{status_code: 200, body: body} = response
    Poison.decode!(body)
  end

  defp handle_response({:error, response}) do
    {:error, "#{inspect response}"}
  end
end