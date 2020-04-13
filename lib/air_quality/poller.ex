defmodule AirQuality.Poller do
  use GenServer

  alias AirQuality.Intensity
  alias AirQuality.Store

  @interval 1_000 * 60 * 30

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def init(_) do
    schedule_tick_after(1_000)
    {:ok, ~D[2018-01-01] |> Timex.to_unix}
  end

  def handle_info(:tick, timestamp) do
    Intensity.fetch_and_store_missing_since(timestamp)
    [{:intensity, timestamp, _, _}] = Store.last()

    schedule_tick_after(millisecs_to_next_slot())
    {:noreply, timestamp}
  end

  defp schedule_tick_after(interval) do
    Process.send_after(self(), :tick, interval)
  end

  defp millisecs_to_next_slot do
    now = :erlang.system_time(:millisecond)
    div(now + @interval, @interval) * @interval - now
  end
end
