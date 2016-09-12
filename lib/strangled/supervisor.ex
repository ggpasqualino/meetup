defmodule Strangled.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Logger.info("#{__MODULE__} started")
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      supervisor(Strangled.ServerSupervisor, []),
      worker(Strangled.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end
end
