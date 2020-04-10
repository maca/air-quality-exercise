defmodule AirQuality.Client do
  alias AirQuality.Store
  import Store, only: [intensity: 1]


  def intensity do
    get("intensity")
  end

  def get(path) do
    url = "#{endpoint()}/#{path}"

    %{ "data" => data } = HTTPoison.get!(url).body |> Poison.decode!
    Enum.map(data, &map_intensity/1)
  end

  def map_intensity(result) do
    %{ "from" => time,
       "intensity" => %{
         "actual" => actual, "forecast" => forecast
       }
    } = result

    timestamp = Timex.parse!(time, "{ISO:Extended:Z}") |> Timex.to_unix

    intensity(timestamp: timestamp, actual: actual, forecast: forecast)
  end

  defp endpoint do
    Application.fetch_env!(:air_quality, :api_host)
  end
end
