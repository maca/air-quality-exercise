defmodule AirQuality.Utils do
  def day_start(timestamp) do
    interval_start(timestamp, 60 * 60 * 24)
  end

  def interval_start(timestamp, interval) do
    div(timestamp, interval) * interval
  end

  def next_interval_start(timestamp, interval) do
    interval_start(timestamp + interval, interval)
  end
end
