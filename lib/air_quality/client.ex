defmodule AirQuality.Client do
  alias AirQuality.Store
  import Store, only: [intensity: 1]

  @endpoint "https://api.carbonintensity.org.uk"


  def get_intensity do
    get("intensity")
  end

  def get(path) do
    url = "#{@endpoint}/#{path}"

    %{ "data" => data } = HTTPoison.get!(url).body |> Poison.decode!
    Enum.map(data, &map_intensity/1)
  end

  def map_intensity(result) do
    %{ "from" => timestamp_raw,
       "intensity" => %{
         "actual" => actual, "forecast" => forecast
       }
    } = result

    timestamp =
      Timex.parse!(timestamp_raw, "{ISO:Extended:Z}") |> Timex.to_unix

    intensity(timestamp: timestamp, actual: actual, forecast: forecast)
  end
end
