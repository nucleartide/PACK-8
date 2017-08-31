
defmodule Periodically do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # schedule work to be performed on start
    {:ok, state}
  end

  def handle_info(:work, state) do
    # do work
    # ...

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 2 * 60 * 60 * 1000) # in 2 hours
  end
end
