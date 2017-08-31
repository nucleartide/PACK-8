defmodule Stack do
  use GenServer

  #
  # Callbacks
  #

  def handle_call(:pop, _from, [h | t]) do
    {:reply, h, t}
  end

  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
  end
end

defmodule BetterStack do
  use GenServer

  #
  # Client.
  #

  # default is initial state?
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def push(pid, item) do
    GenServer.cast(pid, {:push, item})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  #
  # Server (callbacks).
  #

  def handle_call(:pop, _from, [h | t]) do
    {:reply, h, t}
  end

  # call default impl
  def handle_call(request, from, state) do
    super(request, from, state)
  end

  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
  end

  # call default impl
  def handle_cast(request, state) do
    super(request, state)
  end
end
