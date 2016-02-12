defmodule Meetup.Group do
  @api_key System.get_env("MEETUP_API_KEY")
  @endpoint "https://api.meetup.com/2/profiles"

  def members(group, page \\ 20)
  def members(group, page) do
    params = %{
      group_urlname: group,
      key: @api_key,
      sign: true,
      page: page
    }

    @endpoint
    |> HTTPoison.get([], params: params )
    |> case do
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> Poison.decode!(body)
         response -> {:error, "#{inspect response}"}
       end
    |> Map.get("results")
  end
end
