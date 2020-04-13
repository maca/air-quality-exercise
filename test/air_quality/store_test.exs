defmodule AirQuality.StoreTest do
  use ExUnit.Case

  alias AirQuality.Store
  alias :mnesia, as: Mnesia

  import AirQuality.Utils
  import Store, only: [intensity: 1]

  doctest Store

  setup_all do
    on_exit(&Store.stop/0)
  end

  setup do
    Store.init
    Mnesia.clear_table(:intensity)
    :ok
  end

  test "write single intensity" do
    Store.write(one())
    assert all_records() == [ one() ]
  end

  test "write list of intensities" do
    records = [ one(), two(), three(), four() ]
    Store.write(records)
    assert all_records() == records
  end

  test "read intensities by timestamp" do
    Store.write([ one(), two(), three(), four() ])

    assert Store.read(1) == [ one() ]
    assert Store.read(2) == [ two() ]
    assert Store.read(3) == [ three() ]
    assert Store.read(0) == [ ]
  end

  test "read intensities by range" do
    Store.write([ one(), two(), three(), four() ])

    assert Store.read(1, 1) == [ one() ]
    assert Store.read(1, 2) == [ one(), two() ]
    assert Store.read(2, 4) == [ two(), three(), four() ]
    assert Store.read(-1, 4) == [ one(), two(), three(), four() ]
    assert Store.read(5, 10) == [ ]
  end

  test "obtain date timestamps for missing records" do
    from = Timex.shift(Timex.today, days: -3) |> Timex.to_unix
    to = :erlang.system_time(:seconds)
    time_slots = :lists.seq(from, to, half_hour_interval())

    :ok = record_fixtures(time_slots) |> Store.write
    assert Store.dates_for_missing_since(from) |> Enum.to_list == []

    Enum.reduce((1..15), [], fn _, dates ->
      ts = Enum.random(time_slots)
      {:atomic, :ok} = delete(ts)

      dates = [ day_start(ts) | dates ] |> Enum.uniq |> Enum.sort
      missing = Store.dates_for_missing_since(from) |> Enum.to_list
      assert missing == dates
      dates
    end)
  end

  defp one do
    intensity(timestamp: 1, actual: 10, forecast: 11)
  end

  defp two do
    intensity(timestamp: 2, actual: 11, forecast: 12)
  end

  defp three do
    intensity(timestamp: 3, actual: 12, forecast: 13)
  end

  defp four do
    intensity(timestamp: 4, actual: 13, forecast: 14)
  end

  defp record_fixtures(timestamps) do
    Enum.map(timestamps, fn ts ->
      intensity(timestamp: ts, actual: 10, forecast: 10)
    end)
  end

  defp delete(ts) do
    Mnesia.transaction(fn -> Mnesia.delete({:intensity, ts}) end)
  end

  defp half_hour_interval, do: 60 * 30

  defp all_records do
    {:atomic, result} = Mnesia.transaction fn ->
      Mnesia.foldr(fn rec, acc -> [ rec | acc] end, [], :intensity)
    end

    result
  end
end
