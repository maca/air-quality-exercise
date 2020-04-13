defmodule AirQuality.Client do
  require AirQuality.Store
  import AirQuality.Store, only: [intensity: 1]

  def last, do: get("intensity")

  def records(date) when is_binary(date) do
    get("intensity/date/#{date}")
  end

  def records(date) do
    records Timex.format!(date, "{YYYY}-{0M}-{0D}")
  end

  def get(path) do
    url = "#{api_host()}/#{path}"

    %{ "data" => data } = HTTPoison.get!(url).body |> Poison.decode!
    Enum.map(data, &map_record/1)
  end

  defp map_record(result) do
    %{ "from" => time,
       "intensity" => %{
         "actual" => actual, "forecast" => forecast
       }
    } = result
    timestamp = Timex.parse!(time, "{ISO:Extended:Z}") |> Timex.to_unix

    intensity(timestamp: timestamp, actual: actual, forecast: forecast)
  end

  defp api_host do
    Application.fetch_env!(:air_quality, :api_host)
  end
end
