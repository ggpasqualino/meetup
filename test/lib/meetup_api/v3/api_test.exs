defmodule MeetupApi.V3.ApiTest do
  use ExUnit.Case, async: false

  alias MeetupApi.V3.Api
  import Mock

  test "can parse body and links" do
    with_fixture fn ->
      expected =
        {
          :ok,
          %{
            meta: %{"Link" => %{"next" => "/budapest-elixir/members?page=1&offset=1"}},
            result: [%{"name" => "one"}]
          }
        }

      actual = Api.get("/budapest-elixir/members?page=1&offset=0")

      assert actual == expected
    end
  end

  defp with_fixture(fun) do
    stub = {:get,
            fn url ->
              {:ok,
               %HTTPoison.Response{
                 status_code: 200,
                 headers: [{"Link", "</budapest-elixir/members?page=1&offset=1>; rel=\"next\""}],
                 body: "[{\"name\":\"one\"}]"}}
            end}

    with_mock HTTPoison, [stub] do
      fun.()
    end
  end
end
