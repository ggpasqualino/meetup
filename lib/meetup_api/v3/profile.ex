defmodule MeetupApi.V3.Profile do
  alias MeetupApi.V3.{Api, Request}

  @spec all(String.t, String.t | none) :: Stream.t(map)
  def all(group, access_token \\ nil)
  def all(group, access_token) do
    import Request, except: [new: 2]

    "/#{group}/members"
    |> Request.new(access_token)
    |> add_offset(0)
    |> add_page(200)
    |> add_only("id")
    |> add_authentication(access_token)
    |> MeetupApi.V3.ResultStream.new
  end

  @spec one(String.t, String.t | none, list(String.t)) :: map
  def one(member_id, access_token \\ nil, extra_fields \\ ["memberships", "topics"])
  def one(member_id, access_token, extra_fields) do
    import Request, except: [new: 2]

    "/members/#{member_id}"
    |> Request.new(access_token)
    |> add_fields(Enum.join(extra_fields, ","))
    |> add_authentication(access_token)
    |> Api.get
  end
end
