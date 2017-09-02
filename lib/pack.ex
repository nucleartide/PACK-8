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
  the regex. (Thanks to https://www.twitch.tv/jumpystick.)
  """
  def parse_requires(lua) do
    ~r/require\s*(\()?\s*(?<quote>['"])([^()'"]+)\k<quote>\s*(?(1)\))/
    |> Regex.scan(lua)
    |> Enum.map(fn [_, _, _, match] -> match end)
  end

  @doc """
  Normalize a path according to Lua's `require` resolution.

  Note that Lua requires are more like Java module names,
  and that dots are replaced with path separators:

    './foo/bar'   -> './foo/bar.lua'
    'foo/bar'     -> './foo/bar.lua'
    'foo.bar'     -> './foo/bar.lua'
    'foo/bar.lua' -> './foo/bar/lua.lua'
  """
  def require(module_path) do
    module_path
    |> String.replace(".", "/")
    |> (fn p -> "./#{p}.lua" end).()
    |> Path.expand
  end

  @doc """

      iex> Pack.visit(1, %{1 => [2, 3], 2 => [1], 3 => [1]}).map
      %{1 => true, 2 => true, 3 => true}

  """
  def visit(start, nodes, visited \\ MapSet.new()) do
    adj = nodes[start]
    acc = visited |> MapSet.put(start)

    Enum.reduce(adj, acc, fn (n, acc) ->
      case MapSet.member?(acc, n) do
        true  -> acc
        false -> visit(n, nodes, acc)
      end
    end)
  end
end
