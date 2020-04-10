defmodule AirQuality.Store do
  alias :mnesia, as: Mnesia
  require Record

  @record :intensity
  Record.defrecord @record, timestamp: nil, actual: nil, forecast: nil


  def init do
    Application.fetch_env!(:mnesia, :dir) |> File.mkdir_p!

    Mnesia.create_schema(nodes())
    Mnesia.start()

    Mnesia.create_table(@record, attributes: attributes(),
      type: :ordered_set, disc_copies: nodes())

    Mnesia.wait_for_tables([@record], 5)
  end

  def stop do
    Mnesia.stop()
  end

  def write(intensities) when is_list(intensities) do
    run(fn -> Enum.each(intensities, &Mnesia.write/1) end)
  end

  def write(intensity) do
    run(fn -> Mnesia.write(intensity) end)
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

  defp select(head, guard, result \\ [{{@record,:"$1",:"$2",:"$3"}}]) do
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
