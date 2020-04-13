defmodule AirQuality.Store do
  alias :mnesia, as: Mnesia

  require Record
  require Logger

  @record :intensity
  Record.defrecord @record, timestamp: nil, actual: nil, forecast: nil

  def init do
    Application.fetch_env!(:mnesia, :dir) |> File.mkdir_p!

    Mnesia.create_schema(nodes())
    Mnesia.start()

    Mnesia.create_table(@record, attributes: attributes(),
      type: :ordered_set, disc_copies: nodes())

    Mnesia.wait_for_tables([@record], 5_000)
  end

  def stop do
    Mnesia.stop()
  end

  def write(intensities) when is_list(intensities) do
    run(fn -> Enum.each(intensities, &do_write/1) end)
  end

  def write(intensity) do
    run(fn -> do_write(intensity) end)
  end

  def read(timestamp) do
    run(fn -> Mnesia.read({@record, timestamp}) end)
  end

  def read(from, to) do
    guard = [ {:>=, :"$1", from}, {:'=<', :"$1", to} ]
    select({@record, :"$1", :"$2", :"$3"}, guard)
  end

  def last do
    run(fn -> Mnesia.read({@record, Mnesia.last(@record)}) end)
  end

  def dates_for_missing_since(timestamp) do
    missing(timestamp) |> Stream.map(&day_start/1) |> Stream.dedup
  end

  defp missing(timestamp) do
    intervals(timestamp) |> Stream.flat_map(&missing_help/1)
  end

  defp missing_help(ts) do
    case read(ts) do
      [] -> [ts]
      _ -> []
    end
  end

  defp do_write(record) do
    Logger.info(["Writing record: ", inspect(record)])
    Mnesia.write(record)
  end

  defp intervals(since) do
    now = :erlang.system_time(:seconds)
    half_hour = 60 * 30

    Stream.unfold(day_start(since), fn n ->
      ts = n + half_hour
      if ts <= now, do: {n, ts}, else: nil
    end)
  end

  def day_start(timestamp) do
    day = 60 * 60 * 24
    div(timestamp, day) * day
  end

  defp select(head, guard) do
    select(head, guard, [{head}])
  end

  defp select(head, guard, result) do
    run(fn -> Mnesia.select(@record, [{head, guard, result}]) end)
  end

  defp run(fun) do
    {:atomic, result} = Mnesia.transaction(fun)
    result
  end

  defp nodes do
    [node()]
  end

  defp attributes do
    [:timestamp, :actual, :forecast]
  end
end
