defmodule AirQuality.Intensity do
  alias AirQuality.Client
  alias AirQuality.Store


  def fetch_and_store_missing_since(since) when is_integer(since) do
    Store.dates_for_missing_since(since)
      |> Task.async_stream(&fetch_and_store/1)
      |> Stream.run
  end

  def fetch_and_store_missing_since(since) do
    fetch_and_store_missing_since(since |> Timex.to_unix)
  end

  defp fetch_and_store, do: Client.intensity |> Store.write
  defp fetch_and_store(nil), do: nil
  defp fetch_and_store(timestamp) do
    Timex.from_unix(timestamp) |> Client.intensity |> Store.write
  end
end
