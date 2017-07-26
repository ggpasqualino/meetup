defmodule MeetupApi.V3.ResultStreamTest do
  use ExUnit.Case, async: true

  alias MeetupApi.V3.{Request, ResultStream}

  test ".new returns a new ResultStream" do
    request =
      "/budapest-elixir/members"
      |> Request.new("user")
      |> Request.add_page(1)
      |> Request.add_offset(0)

    assert is_function ResultStream.new(request)
  end

  test "can return all results" do
    fetcher_mock = fn(%Request{params: params}) ->
      if params.offset == 0 do
        first_page()
      else
        last_page()
      end
    end

    actual =
      "/budapest-elixir/members"
      |> Request.new("user")
      |> Request.add_page(1)
      |> Request.add_offset(0)
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
