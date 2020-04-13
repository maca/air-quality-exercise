defmodule AirQuality do
  alias AirQuality.Poller

  use Application

  def start(_type, _args) do
    :ok = AirQuality.Store.init

    children = [{Poller, []}]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
