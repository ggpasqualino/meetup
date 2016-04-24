defmodule MeetupApi.V3.ApiTest do
  use ExUnit.Case, async: true

  alias MeetupApi.V3.Api

  test "can parse body and links" do
    request_mock = fn _ ->
      {
        :ok,
        %HTTPoison.Response{
          status_code: 200,
          headers: [{"Link", "</budapest-elixir/members?page=1&offset=1>; rel=\"next\""}],
          body: "[{\"name\":\"one\"}]"
        }
      }
    end

    expected =
      {
        :ok,
        %{
          meta: %{"Link" => %{"next" => "/budapest-elixir/members?page=1&offset=1"}},
          result: [%{"name" => "one"}]
        }
      }

    actual = Api.get("/budapest-elixir/members?page=1&offset=0", request_mock)

    assert actual == expected
  end
end
