defmodule AirQuality.ClientTest do
  use ExUnit.Case

  import AirQuality.Store, only: [intensity: 1]
  alias AirQuality.Client

  test "get intensity" do
    expected = [intensity(timestamp: 0, actual: 1, forecast: 2)]
    assert Client.intensity == expected
  end

  test "get intensities at date" do
    timestamp = 60 * 60 * 24
    timestamp2 = timestamp + 60 * 30
    expected = [
      intensity(timestamp: timestamp, actual: 1, forecast: 2),
      intensity(timestamp: timestamp2, actual: 2, forecast: 3)
    ]

    assert Client.intensity(~D[1970-01-02]) == expected
  end

  test "get intensities at date as string" do
    timestamp = 60 * 60 * 24
    timestamp2 = timestamp + 60 * 30
    expected = [
      intensity(timestamp: timestamp, actual: 1, forecast: 2),
      intensity(timestamp: timestamp2, actual: 2, forecast: 3)
    ]

    assert Client.intensity("1970-01-02") == expected
  end
end
