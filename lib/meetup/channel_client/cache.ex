defmodule Meetup.ChannelClient.Cache do
  @moduledoc """
  This module is used to lookup for running Meetup.ChannelClient.Server for a given client
and group channel or start one
  """
  use GenServer
  require Logger

  def start_link do
    Logger.info("#{__MODULE__} started")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(client, channel) do
    case Meetup.ChannelClient.Server.whereis(client, channel) do
      :undefined ->
        GenServer.call(__MODULE__, {:server_process, client, channel})
      pid -> pid
    end
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:server_process, client, channel}, _, state) do
    server_pid =
      case Meetup.ChannelClient.Server.whereis(client, channel) do
        :undefined ->
          {:ok, pid} = Meetup.ChannelClient.ServerSupervisor.start_child(client, channel)
          pid
        pid -> pid
      end
    {:reply, server_pid, state}
  end
end
