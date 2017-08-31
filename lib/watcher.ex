
defmodule Watcher do
  use GenServer

  def start_link([{:dirs, path}] = args) do
    #IO.puts(path)
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, state) do
    IO.puts("first info")
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, state) do
    IO.puts("second info")
    {:noreply, state}
  end
end
