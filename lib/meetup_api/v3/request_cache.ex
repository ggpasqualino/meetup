defmodule MeetupApi.V3.RequestCache do
  use GenServer
  require Logger

  @timeout Application.get_env(:meetup, Strangled.Server)[:user_expiration_time] * 1000
  @ttl 86_400_000

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def cached(key, fun) do
    read_cached(key) ||
      cache_response(key, fun)
  end

  defp read_cached(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, cached_request}] -> cached_request
      _ -> nil
    end
  end

  defp cache_response(key, fun) do
    response = fun.()
    :ets.insert(__MODULE__, {key, response})
    schedule_clean_up(key)
    response
  end

  defp schedule_clean_up(key) do
    Process.send_after(__MODULE__, {:clean_up, key}, @ttl)
  end

  # Server callbacks

  def init(_) do
    :ets.new(__MODULE__, [:set, :named_table, :public])
    {:ok, nil}
  end

  def handle_info({:clean_up, key}, state) do
    Logger.debug("#{__MODULE__} clean_up #{key}")
    :ets.delete(__MODULE__, key)
    {:noreply, state}
  end
end
