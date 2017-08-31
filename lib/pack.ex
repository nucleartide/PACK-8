defmodule Pack do
  def main(args) do
    :fs.start_link(:my_watcher, Path.absname("."))
    :fs.subscribe(:my_watcher)
    receive do
        {_watcher_process, {:fs, :file_event}, {changedFile, _type}} ->
             IO.puts("#{changedFile} was updated")
        anything -> IO.puts "shit"
    end
    # flush()

#    {:ok, pid} = FileSystem.start_link(dirs: ["/Users/jason/Repositories/pack"])
#    FileSystem.subscribe(pid)
#
#    receive do
#      something -> IO.puts(something)
#    end
  end

  def process([]) do
    IO.puts "no args bro"
  end
  def process(options) do
    IO.puts "hello #{options[:name]}"
  end

  defp parse(args) do
    {options, _, _} = OptionParser.parse(args, switches: [foo: :string])
    options
  end
end
