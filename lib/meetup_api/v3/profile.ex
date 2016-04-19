defmodule MeetupApi.V3.Profile do
  alias MeetupApi.V3.Api

  @spec all(String.t) :: Stream.t(map)
  def all(group) do
    params =
      %{
        key: Api.key,
        page: 200,
        offset: 0,
        fields: "memberships,topics"
      }

    "/#{group}/members"
    |> Api.build_url(params)
    |> MeetupApi.V3.ResultStream.new
  end

  @spec one(String.t, list(String.t)) :: map
  def one(member_id, extra_fields \\ ["memberships", "topics"])
  def one(member_id, extra_fields) do
    params = %{
      key: Api.key,
      fields: Enum.join(extra_fields, ",")
    }

    Api.get("/members/#{member_id}", params)
  end
end
