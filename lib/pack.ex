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

  @doc """
  Given a string of Lua code, parse out `require` calls and
  return a list of required paths.

  See https://regex101.com/r/kzY8rx/4 for an explanation of
  the regex.

  (Thanks to https://www.twitch.tv/jumpystick for the help.)
  """
  def parse_requires(lua) do
    Regex.scan(~r/require\s*(\()?\s*(?<quote>['"])([^()'"]+)\k<quote>\s*(?(1)\))/, lua)
    |> Enum.map(fn [_, _, _, match] -> match end)
  end
end
