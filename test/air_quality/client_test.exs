defmodule AirQuality.ClientTest do
  use ExUnit.Case

  import AirQuality.Store, only: [intensity: 1]
  alias AirQuality.Client

  test "get intensity" do
    expected = [intensity(timestamp: 1, actual: 1, forecast: 2)]
    assert Client.intensity == expected
  end
end
