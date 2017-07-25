defmodule MeetupApi.Cache do
  @moduledoc """
  This module is used to lookup for running MeetupApi.Server for a given client
 or start one
  """
  use GenServer
  require Logger

  def start_link do
    Logger.info("#{__MODULE__} started")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(client) do
    case MeetupApi.Server.whereis(client) do
      :undefined ->
        GenServer.call(__MODULE__, {:server_process, client})
      pid -> pid
    end
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:server_process, client}, _, state) do
    meetup_api_server_pid =
      case MeetupApi.Server.whereis(client) do
        :undefined ->
          {:ok, pid} = MeetupApi.ServerSupervisor.start_child(client)
          pid
        pid -> pid
      end
    {:reply, meetup_api_server_pid, state}
  end
end
