defmodule Meetup.ChannelClient.Supervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link do
    Logger.info("#{__MODULE__} started")
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      supervisor(Meetup.ChannelClient.ServerSupervisor, []),
      worker(Meetup.ChannelClient.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end
end
