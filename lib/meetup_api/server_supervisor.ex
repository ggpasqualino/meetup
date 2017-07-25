defmodule MeetupApi.ServerSupervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link do
    Logger.info("#{__MODULE__} started")
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def start_child(client) do
    Supervisor.start_child(__MODULE__, [client])
  end

  def init(_) do
    supervise([worker(MeetupApi.Server, [])], strategy: :simple_one_for_one)
  end
end
