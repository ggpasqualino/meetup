defmodule Strangled.Server do
  use GenServer
  require Logger

  defmodule State do
    defstruct [:strangled_user, :wait_queue, :max_rate, :current_rate, :time_interval]
  end

  @max_rate Application.get_env(:meetup, __MODULE__)[:max_rate]
  @time_interval Application.get_env(:meetup, __MODULE__)[:time_interval]
  @user_expiration_time Application.get_env(:meetup, __MODULE__)[:user_expiration_time] * 1000

  # Client API

  def start_link(strangled_user, max_rate \\ @max_rate, time_interval \\ @time_interval) do
    Logger.info("#{__MODULE__} for '#{strangled_user}' started")
    init_state = %State{
      strangled_user: strangled_user,
      wait_queue: [],
      max_rate: max_rate,
      current_rate: max_rate,
      time_interval: time_interval}

    GenServer.start_link(__MODULE__, init_state, name: via_tuple(strangled_user))
  end

  def wait_permission(pid, timeout \\ @user_expiration_time) do
    GenServer.call(pid, :request_permission, timeout)
  end

  def allow?(pid) do
    GenServer.call(pid, :allow?)
  end

  def whereis(strangled_user) do
    :gproc.whereis_name({:n, :l, {:strangled_server, strangled_user}})
  end

  # Genserver callbacks

  def init(state) do
    Process.send_after(self, :answer_queue, state.time_interval * 1000)
    Process.send_after(self, :clean_up, @user_expiration_time)
    {:ok, state}
  end

  def handle_call(:request_permission, from, state) do
    Logger.debug("request_permission started, state: #{inspect state}")
    if permited?(state) do
      {:reply, :ok, decrease_rate(state)}
    else
      {:noreply, enqueue(state, from)}
    end
  end

  def handle_call(:allow?, _from, state) do
    Logger.debug("allow? started, state: #{inspect state}")
    if permited?(state) do
      {:reply, true, decrease_rate(state)}
    else
      {:reply, false, state}
    end
  end

  def handle_info(:answer_queue, %State{time_interval: time_interval} = state) do
    Logger.debug("answer_queue started, state: #{inspect state}")
    new_state = state |> answer_queue

    Process.send_after(self, :answer_queue, time_interval * 1000)

    {:noreply, new_state}
  end

  def handle_info(:clean_up, state) do
    {:stop, :normal, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def permited?(%State{current_rate: current_rate}) do
    current_rate > 0
  end

  def decrease_rate(%State{current_rate: current_rate} = state) do
    %State{state | current_rate: current_rate - 1}
  end

  def enqueue(%State{wait_queue: wait_queue} = state, from) do
    %State{state | wait_queue: wait_queue ++ [from]}
  end

  def answer_queue(%State{wait_queue: wait_queue, max_rate: max_rate} = state) do
    {froms, rest} = Enum.split(wait_queue, max_rate)
    Enum.each(froms, fn(f) -> GenServer.reply(f, :ok) end)

    %State{state | wait_queue: rest, current_rate: max_rate - length(froms)}
  end

  def via_tuple(strangled_user) do
    {:via, :gproc, {:n, :l, {:strangled_server, strangled_user}}}
  end
end
