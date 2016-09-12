defmodule Strangled.ServerSupervisor do
  use Supervisor
  require Logger

  def start_link do
    Logger.info("#{__MODULE__} started")
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def start_child(strangled_user) do
    Supervisor.start_child(__MODULE__, [strangled_user])
  end

  def init(_) do
    supervise([worker(Strangled.Server, [])], strategy: :simple_one_for_one)
  end
end
