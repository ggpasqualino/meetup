defmodule Meetup.ChannelClient.ServerSupervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link do
    Logger.info("#{__MODULE__} started")
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def start_child(client, channel) do
    Supervisor.start_child(__MODULE__, [client, channel])
  end

  def init(_) do
    supervise([worker(Meetup.ChannelClient.Server, [])], strategy: :simple_one_for_one)
  end
end
