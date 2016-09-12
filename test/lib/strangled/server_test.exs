defmodule Strangled.ServerTest do
  use ExUnit.Case, async: true

  test "wait_permission" do
    {:ok, pid} = Strangled.Server.start_link('user')

    do_with_permission = fn test_pid, x ->
      :ok = Strangled.Server.wait_permission(pid)
      send(test_pid, x)
    end

    Enum.each(1..3, fn x ->
      test_pid = self
      spawn(fn -> do_with_permission.(test_pid, x) end)
    end)

    assert_receive 1, 2000
    assert_receive 2, 2000
    assert_receive 3, 2000
  end

  test "allow?" do
    {:ok, pid} = Strangled.Server.start_link('user')

    do_with_permission = fn test_pid ->
      send(test_pid, Strangled.Server.allow?(pid))
    end

    Enum.each(1..2, fn _ ->
      test_pid = self
      spawn(fn -> do_with_permission.(test_pid) end)
    end)

    assert_receive true
    assert_receive false
  end

  test "clean up after user expiration" do
    {:ok, pid} = Strangled.Server.start_link('user')

    Process.monitor(pid)

    assert_receive {:DOWN, _, _, ^pid, :normal}, 5000
  end
end
