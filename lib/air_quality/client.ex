defmodule AirQuality.Client do
  alias AirQuality.Store
  require Store

  def intensity(date) when is_binary(date) do
    get("intensity/date/#{date}")
  end

  def intensity(date) do
    intensity Timex.format!(date, "{YYYY}-{0M}-{0D}")
  end

  def intensity do
    get("intensity")
  end

  def get(path) do
    url = "#{endpoint()}/#{path}"

    %{ "data" => data } = HTTPoison.get!(url).body |> Poison.decode!
    Enum.map(data, &map_intensity/1)
  end

  defp map_intensity(result) do
    %{ "from" => time,
       "intensity" => %{
         "actual" => actual, "forecast" => forecast
       }
    } = result

    timestamp = Timex.parse!(time, "{ISO:Extended:Z}") |> Timex.to_unix

    Store.intensity(timestamp: timestamp, actual: actual,
      forecast: forecast)
  end

  defp endpoint do
    Application.fetch_env!(:air_quality, :api_host)
  end
end
