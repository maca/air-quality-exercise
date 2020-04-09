defmodule AirQuality.Poller do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(opts \\ []) do
    {:ok, opts}
  end

  # def handle_call(:pop, _from, [head | tail]) do
  #   {:reply, head, tail}
  # end

  # def handle_cast({:push, element}, state) do
  #   {:noreply, [element | state]}
  # end
end
