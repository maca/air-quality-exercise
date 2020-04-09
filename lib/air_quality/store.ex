defmodule AirQuality.Intensity do
  alias :mnesia, as: Mnesia

  defstruct timestamp: nil, actual: nil, forecast: nil
  @minute_interval 30


  def init_store do
    Mnesia.create_schema(nodes())
    Mnesia.start()

    Mnesia.create_table(__MODULE__, attributes: attributes(),
      type: :ordered_set, index: [:timestamp], disc_copies: nodes())
  end


  def store(intensities) when is_list(intensities) do
    Mnesia.transaction(fn -> Enum.map(intensities, &write/1) end)
  end

  def store(intensity) do
    Mnesia.transaction(fn -> write(intensity) end)
  end


  def read(timestamp) when is_number(timestamp) do
    Mnesia.transaction(fn -> Mnesia.read({__MODULE__, timestamp}) end)
  end

  def read(timestamp) do
    read unix_time(timestamp)
  end


  def read_interval([from: from, to: to]) do
    guard = [ {:>=, :"$1", unix_time(from)},
              {:'=<', :"$1", unix_time(to)} ]

    select({:_, :"$1", :"$2", :"$3"}, guard)
  end

  def last do
    Mnesia.transaction(fn ->
      Mnesia.read({__MODULE__, Mnesia.last(__MODULE__)})
    end)
  end


  defp select(head, guard, result \\ [:"$$"]) do
    params = [{head, guard, result}]

    Mnesia.transaction(fn ->
      Mnesia.select(__MODULE__, params) |> Enum.map(&map_record/1)
    end)
  end

  defp map_record([ts, ac, fc]) do
    timestamp = Timex.from_unix(ts)
    %__MODULE__{timestamp: timestamp, actual: ac, forecast: fc}
  end

  defp snap_time(time = %{minute: minute}) do
    minute = floor(minute / @minute_interval) * @minute_interval
    Timex.set(time, minute: minute, second: 0, microsecond: {0, 0})
  end

  defp write(%{timestamp: ts, actual: actual, forecast: forecast}) do
    Mnesia.write({__MODULE__, unix_time(ts), actual, forecast})
  end

  defp unix_time(timestamp) do
    snap_time(timestamp) |> Timex.to_unix
  end

  defp nodes do
    [node()]
  end

  defp attributes do
    [_ | attrs] = Map.keys(AirQuality.Intensity.__struct__)
    attrs
  end
end
