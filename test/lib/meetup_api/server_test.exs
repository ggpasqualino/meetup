defmodule MeetupApi.ServerTest do
  use ExUnit.Case, async: true

  describe "do_request" do
    test "under the limit" do
      {:ok, pid} = MeetupApi.Server.start_link('user')

      request = fn ->
        {:ok, %{
          meta:
          %{
            "X-RateLimit-Limit" => ["3"],
            "X-RateLimit-Remaining" => ["3"],
            "X-RateLimit-Reset" => ["1"],
          }
        }}
      end

      test_pid = self()
      Enum.each(1..3, fn x ->
        spawn(fn ->
          MeetupApi.Server.do_request(pid, request)
          send(test_pid, x)
        end)
      end)

      assert_receive 1, 100
      assert_receive 2, 100
      assert_receive 3, 100
    end

    test "over the limit" do
      {:ok, pid} = MeetupApi.Server.start_link('user')

      request = fn ->
        {:ok, %{
          meta:
          %{
            "X-RateLimit-Limit" => ["1"],
            "X-RateLimit-Remaining" => ["0"],
            "X-RateLimit-Reset" => ["1"],
          }
        }}
      end

      test_pid = self()
      Enum.each(1..3, fn x ->
        spawn(fn ->
          MeetupApi.Server.do_request(pid, request)
          send(test_pid, x)
        end)
      end)

      assert_receive 1, 100

      refute_receive 2, 100
      assert_receive 2, 1600

      refute_receive 3, 100
      assert_receive 3, 1600
    end
  end

  test "clean up after user expiration" do
    {:ok, pid} = MeetupApi.Server.start_link('user')

    Process.monitor(pid)

    assert_receive {:DOWN, _, _, ^pid, :normal}, 5000
  end
end
