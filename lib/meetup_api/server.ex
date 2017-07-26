defmodule MeetupApi.Server do
  @moduledoc """
    This is the server which will do the request to the meetup api.
    There should be one server for each client (token) in order to garantee that
 the client won't go over the request limit and get throttled.
  """
  use GenServer
  require Logger

  defmodule State do
    @moduledoc false
    defstruct [:client, :wait_queue, :limit, :remaining, :seconds_to_reset]

    def update(state, {:ok, api_response}) do
      limit = api_response |> get_in([:meta, "X-RateLimit-Limit"]) |> List.first |> String.to_integer
      remaining = api_response |> get_in([:meta, "X-RateLimit-Remaining"]) |> List.first |> String.to_integer
      seconds_to_reset = api_response |> get_in([:meta, "X-RateLimit-Reset"]) |> List.first |> String.to_integer
      %{state |
        limit: limit,
        remaining: remaining,
        seconds_to_reset: seconds_to_reset
      }
    end

    def pop_wait_queue(state) do
      %{state | wait_queue: Enum.drop(state.wait_queue, 1)}
    end

    def permited?(state) do
      is_nil(state.remaining) || state.remaining > 0
    end
  end

  @user_expiration_time Application.get_env(:meetup, :user_expiration_time) * 1000

  # Client API

  def start_link(client) do
    Logger.info("#{__MODULE__} for '#{client}' started")
    initial_state = %State{client: client, wait_queue: []}
    GenServer.start_link(__MODULE__, initial_state, name: via_tuple(client))
  end

  defp via_tuple(client) do
    {:via, :gproc, {:n, :l, {:meetup_api_server, client}}}
  end

  def do_request(pid, request, timeout \\ @user_expiration_time) do
    GenServer.call(pid, {:do_request, request}, timeout)
  end

  def whereis(client) do
    :gproc.whereis_name({:n, :l, {:meetup_api_server, client}})
  end

  # Genserver callbacks

  def init(state) do
    Process.send_after(self, :clean_up, @user_expiration_time)
    {:ok, state}
  end

  def handle_call({:do_request, request}, from, state) do
    Logger.debug(":do_request started, state: #{inspect state}")
    if State.permited?(state) do
      response = request.()
      state = State.update(state, response)
      schedule_queue_processing(state)
      {:reply, response, state}
    else
      {:noreply, enqueue(state, from, request)}
    end
  end

  defp enqueue(%State{wait_queue: wait_queue} = state, from, request) do
    %State{state | wait_queue: wait_queue ++ [{from, request}]}
  end

  def handle_info(:answer_queue, state) do
    Logger.debug("answer_queue started, state: #{inspect state}")
    state = answer_queue(state)
    schedule_queue_processing(state)
    {:noreply, state}
  end

  defp answer_queue(%State{wait_queue: wait_queue} = state) do
    Enum.reduce_while(wait_queue, state, fn({f, request}, s) ->
      response = request.()
      GenServer.reply(f, response)
      s = s |> State.update(response) |> State.pop_wait_queue()
      if s.remaining > 0, do: {:cont, s}, else: {:halt, s}
    end)
  end

  defp schedule_queue_processing(state) do
    if state.remaining == 0 do
      Process.send_after(self, :answer_queue, state.seconds_to_reset * 1000 + 500)
    end
  end

  def handle_info(:clean_up, state) do
    {:stop, :normal, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
