defmodule MeetupApi.V3.ResultStreamTest do
  use ExUnit.Case, async: false

  alias MeetupApi.V3.{Api, ResultStream}
  import Mock

  test ".new returns a new ResultStream" do
    assert is_function ResultStream.new("/budapest-elixir/members?page=1&offset=0")
  end

  test "can return all results" do
    url = "/budapest-elixir/members?page=1&offset=0"
    with_fixture fn ->
      expected = [%{"name" => "one"}, %{"name" => "two"}]
      actual =
        url
        |> ResultStream.new
        |> Enum.to_list

      assert actual == expected
    end
  end

  defp with_fixture(fun) do
    stub = {:get,
            fn url ->
              if String.match?(url, ~r/.*offset=0.*/) do
                offset0
              else
                offset1
              end
            end}

    with_mock Api, [stub] do
      fun.()
    end
  end

  defp offset0 do
    {
      :ok,
      %{
        meta: %{"Link" => %{"next" => "/budapest-elixir/members?page=1&offset=1"}},
        result: [%{"name" => "one"}]
      }
    }
  end

  defp offset1 do
    {
      :ok,
      %{
        meta: %{},
        result: [%{"name" => "two"}]
      }
    }
  end
end
