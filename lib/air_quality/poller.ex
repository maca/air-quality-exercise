defmodule AirQuality.Poller do
  use GenServer

  import AirQuality.Utils
  alias AirQuality.Store
  alias AirQuality.Client

  @interval 1_000 * 60 * 30

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def init(_) do
    schedule_tick_after(1_000)
    {:ok, ~D[2018-01-01] |> Timex.to_unix}
  end

  def handle_info(:tick, timestamp) do
    fetch_and_store_missing_since(timestamp)
    [{:intensity, timestamp, _, _}] = Store.last()

    schedule_tick_after(millisecs_until_tick())
    {:noreply, timestamp}
  end

  defp schedule_tick_after(interval) do
    Process.send_after(self(), :tick, interval)
  end

  defp millisecs_until_tick do
    now = :erlang.system_time(:millisecond)
    next_interval_start(now, @interval) - now
  end

  defp fetch_and_store_missing_since(since) do
    Store.dates_for_missing_since(since)
      |> Task.async_stream(&fetch_and_store/1)
      |> Stream.run
  end

  defp fetch_and_store(timestamp) do
    Timex.from_unix(timestamp) |> Client.records |> Store.write
  end
end
