defmodule AirQuality do
  use Application

  def start(_type, _args) do
    :ok = AirQuality.Store.init

    children = [{AirQuality.Poller, []}]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
