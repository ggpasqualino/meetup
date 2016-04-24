defmodule MeetupApi.V3.Profile do
  alias MeetupApi.V3.Api

  @spec all(String.t, String.t | none) :: Stream.t(map)
  def all(group, access_token \\ nil)
  def all(group, access_token) do
    params =
      %{
        page: 200,
        offset: 0,
        fields: "memberships,topics"
      }
    |> add_authentication(access_token)

    "/#{group}/members"
    |> Api.build_url(params)
    |> MeetupApi.V3.ResultStream.new
  end

  @spec one(String.t, String.t | none, list(String.t)) :: map
  def one(member_id, access_token \\ nil, extra_fields \\ ["memberships", "topics"])
  def one(member_id, access_token, extra_fields) do
    params = %{
      fields: Enum.join(extra_fields, ",")
    }
    |> add_authentication(access_token)

    "/members/#{member_id}"
    |> Api.build_url(params)
    |> Api.get
  end

  defp add_authentication(params, nil) do
    Map.put_new(params, :key, Api.key)
  end

  defp add_authentication(params, access_token) do
    Map.put_new(params, :access_token, access_token)
  end
end
