defmodule Strangled.Cache do
  use GenServer
  require Logger

  def start_link do
    Logger.info("#{__MODULE__} started")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(strangled_user) do
    case Strangled.Server.whereis(strangled_user) do
      :undefined ->
        GenServer.call(__MODULE__, {:server_process, strangled_user})
      pid -> pid
    end
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:server_process, strangled_user}, _, state) do
    strangled_server_pid = case Strangled.Server.whereis(strangled_user) do
      :undefined ->
        {:ok, pid} = Strangled.ServerSupervisor.start_child(strangled_user)
        pid

      pid -> pid
    end
    {:reply, strangled_server_pid, state}
  end
end
