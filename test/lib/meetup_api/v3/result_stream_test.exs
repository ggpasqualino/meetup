defmodule MeetupApi.V3.ResultStreamTest do
  use ExUnit.Case, async: true

  alias MeetupApi.V3.{ResultStream}

  test ".new returns a new ResultStream" do
    assert is_function ResultStream.new("/budapest-elixir/members?page=1&offset=0")
  end

  test "can return all results" do
    fetcher_mock = fn url ->
      if String.match?(url, ~r/.*offset=0.*/) do
        first_page
      else
        last_page
      end
    end

    actual =
      "/budapest-elixir/members?page=1&offset=0"
      |> ResultStream.new(fetcher_mock)
      |> Enum.to_list

    expected = [%{"name" => "one"}, %{"name" => "two"}]

    assert actual == expected
  end

  defp first_page do
    {
      :ok,
      %{
        meta: %{"Link" => %{"next" => "/budapest-elixir/members?page=1&offset=1"}},
        result: [%{"name" => "one"}]
      }
    }
  end

  defp last_page do
    {
      :ok,
      %{
        meta: %{},
        result: [%{"name" => "two"}]
      }
    }
  end
end
