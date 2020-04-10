defmodule AirQuality.StoreTest do
  use ExUnit.Case

  alias AirQuality.Store
  alias :mnesia, as: Mnesia

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
    record = intensity(timestamp: 1, actual: 10, forecast: 11)
    Store.write(record)
    assert all_records() == [ record ]
  end

  test "write list of intensities" do
    records =
      [ intensity(timestamp: 1, actual: 10, forecast: 11),
        intensity(timestamp: 2, actual: 11, forecast: 12)
      ]
    Store.write(records)
    assert all_records() == records
  end

  test "read intensities by timestamp" do
    one =intensity(timestamp: 1, actual: 10, forecast: 11)
    two = intensity(timestamp: 2, actual: 11, forecast: 12)

    Store.write([ one, two])
    assert Store.read(1) == [ one ]
    assert Store.read(2) == [ two ]
    assert Store.read(3) == [ ]
    assert Store.read(0) == [ ]
  end

  test "read intensities by range" do
    one = intensity(timestamp: 1, actual: 10, forecast: 11)
    two = intensity(timestamp: 2, actual: 11, forecast: 12)
    three = intensity(timestamp: 3, actual: 12, forecast: 13)
    four = intensity(timestamp: 4, actual: 13, forecast: 14)

    Store.write([ one, two, three, four ])

    assert Store.read(1, 1) == [ one ]
    assert Store.read(1, 2) == [ one, two ]
    assert Store.read(2, 4) == [ two, three, four ]
    assert Store.read(-1, 4) == [ one, two, three, four ]
    assert Store.read(5, 10) == [ ]
  end

  defp all_records do
    {:atomic, result} = Mnesia.transaction fn ->
      Mnesia.foldr(fn rec, acc -> [ rec | acc] end, [], :intensity)
    end

    result
  end
end
