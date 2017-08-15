defmodule MeetupApi.V3.Profile do
  alias MeetupApi.V3.{Api, Request, RequestCache}

  @spec all(String.t, String.t | none) :: Enum.t(map)
  def all(group, access_token \\ nil)
  def all(group, access_token) do
    import Request, except: [new: 2]

    path = "/#{group}/members"

    all_request = fn  ->
      path
      |> Request.new(access_token)
      |> add_offset(0)
      |> add_page(200)
      |> add_only("id")
      |> add_authentication(access_token)
      |> MeetupApi.V3.ResultStream.new
      |> Enum.to_list
    end

    RequestCache.cached(path, all_request)
  end

  @spec one(String.t, String.t | none, list(String.t)) :: map
  def one(member_id, access_token \\ nil, extra_fields \\ ["memberships", "topics"])

  def one("self" = member_id, access_token, extra_fields) do
    one_request(member_id, access_token, extra_fields).()
  end

  def one(member_id, access_token, extra_fields) do
    path = "/members/#{member_id}"
    RequestCache.cached(path, one_request(member_id, access_token, extra_fields))
  end

  defp one_request(member_id, access_token, extra_fields) do
    import Request, except: [new: 2]

    request =
      "/members/#{member_id}"
      |> Request.new(access_token)
      |> add_fields(Enum.join(extra_fields, ","))
      |> add_authentication(access_token)

    fn -> Api.get(request) end
  end
end
