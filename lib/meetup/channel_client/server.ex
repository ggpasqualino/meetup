defmodule Meetup.ChannelClient.Server do
  @moduledoc false
  use GenServer
  require Logger

  alias MeetupApi.V3.Profile

  defmodule State do
    @moduledoc false
    defstruct [:socket, :member_ids, :members, :token, :channel]

    def put_socket(state, socket), do: %State{state | socket: socket}
    def put_member_ids(state, ids), do: %State{state | member_ids: ids}
    def add_member(state, m), do: %State{state | members: [m | state.members]}
  end

  @user_expiration_time Application.get_env(:meetup, :user_expiration_time) * 1000

  # Client API

  def start_link(client, channel) do
    Logger.info("#{__MODULE__} for client='#{client}' and channel='#{channel}' started")
    initial_state = %State{socket: nil, member_ids: [], members: [], token: client, channel: channel}
    GenServer.start_link(__MODULE__, initial_state, name: via_tuple(client, channel))
  end

  defp via_tuple(client, channel) do
    {:via, :gproc, {:n, :l, {:meetup_channel_client_server, client, channel}}}
  end

  def whereis(client, channel) do
    :gproc.whereis_name({:n, :l, {:meetup_channel_client_server, client, channel}})
  end

  def join(pid, socket) do
    GenServer.cast(pid, {:join, socket})
  end

  def member_result(pid, result) do
    GenServer.cast(pid, {:member_result, result})
  end

  # Genserver callbacks

  def init(state) do
    send(self(), :after_init)
    Process.send_after(self(), :clean_up, @user_expiration_time)
    {:ok, state}
  end

  def handle_cast({:join, socket}, state) do
    Logger.info(":join received in #{__MODULE__} with token=#{state.token} and members=#{inspect state.member_ids}")
    state =
      state
      |> State.put_socket(socket)
      |> send_total_members()
      |> send_all_members()
    {:noreply, state}
  end
  def handle_cast({:member_result, member}, state) do
    Logger.info(":member_result received in #{__MODULE__} with token=#{state.token} and members=#{inspect state.member_ids}")
    state =
      state
      |> State.add_member(member)
      |> send_member(member)
    {:noreply, state}
  end

  defp send_total_members(%State{socket: s, member_ids: m} = state) do
    if s, do: Phoenix.Channel.push(s, "total_members", %{total_members: length(m)})
    state
  end

  def send_all_members(%State{socket: s, members: members} = state) do
    if s do
      for m <- Enum.chunk_every(members, 10) do
        Phoenix.Channel.push(s, "members", %{members: m})
      end
    end
    state
  end

  def send_member(%State{socket: s} = state, m) do
    if s, do: Phoenix.Channel.push(s, "member", %{member: m})
    state
  end

  def handle_info(:after_init, state) do
    {:noreply, start_requests(state)}
  end
  def handle_info(:clean_up, state) do
    {:stop, :normal, state}
  end
  def handle_info(_, state) do
    {:noreply, state}
  end

  def start_requests(state) do
    state
    |> all_member_ids()
    |> send_total_members()
    |> all_members()
  end

  def all_member_ids(%State{channel: c, token: t} = state) do
    member_ids = Profile.all(c, t)
    State.put_member_ids(state, member_ids)
  end

  def all_members(%State{member_ids: ids, token: token} = state) do
    pid = self()

    Task.start_link(fn ->
      Enum.each(ids, fn(%{"id" => id}) ->
        {:ok, %{result: member}} = Profile.one(id, token)
        member_result(pid, member)
      end)
    end)

    state
  end
end
