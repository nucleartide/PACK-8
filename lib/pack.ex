defmodule Pack do
  def main(args) do
    file = args
      |> Enum.at(0, "main.lua")

    bundle = case String.ends_with?(file, ".lua") do
      true  -> String.replace(file, ".lua", ".bundle.lua")
      false -> throw("File #{file} does not .lua as its file extension.")
    end

    file
    |> Path.expand
    |> visit
    |> output(Path.expand(file), bundle)
    |> output_p8(String.replace(file, ".lua", ".p8"))

    #    visit(file)
    #|> output
    # |> IO.puts

#    :fs.start_link(:my_watcher, Path.absname("."))
#    :fs.subscribe(:my_watcher)
#    receive do
#        {_watcher_process, {:fs, :file_event}, {changedFile, _type}} ->
#             IO.puts("#{changedFile} was updated")
#        anything -> IO.puts "shit"
#    end
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
  def lua_require(module_path) do
    module_path
    |> String.replace(".", "/")
    |> (fn p -> "./#{p}.lua" end).()
    |> Path.expand
  end

  @doc """
  Perform a DFS traversal of a Lua file's dependency tree.

      iex> Pack.visit("/Users/jason/Repositories/pack/main.lua").map
      %{"/Users/jason/Repositories/pack/main.lua" => true, "/Users/jason/Repositories/pack/test_module.lua" => true}

  """
  def visit(start, visited \\ MapSet.new()) do
    a = cond do
      File.regular?(start) ->
        "blah"
      String.starts_with?(start, "github.com") ->
        "blah"
      true ->
        "throw error"
    end
    IO.puts(a)

    adj = start
      |> File.read!
      |> parse_requires
    acc = visited |> MapSet.put(start)

    Enum.reduce(adj, acc, fn (n, acc) ->
      n = lua_require(n)
      new_acc = case MapSet.member?(acc, n) do
        true  -> acc
        false -> visit(n, acc)
      end
    end)
  end

  @doc """
  https://regex101.com/r/kzY8rx/5
  """
  def replace_require(lua) do
    Regex.replace(
      ~r/require(\s*)(\()?(\s*)(?<quote>['"])([^()'"]+)\k<quote>(?(2)(\s*)\))/,
      lua,
      fn _, _, _, _, _, path, ws6 ->
        path
        |> String.replace(".", "/")
        |> (fn p -> "./#{p}.lua" end).()
        |> Path.expand
        |> (fn p -> "require '#{p}'#{ws6}" end).()
      end
    )
  end

  @doc """
      iex> Pack.output(MapSet.new(["/Users/jason/Repositories/pack/main.lua"]))
      nil


  """
  def output(modules, main, bundle) do
    list = MapSet.to_list(modules)
    IO.inspect list
    module_list = list
      |> Enum.map(fn f ->
        File.read!(f)
        |> replace_require
        |> (fn source -> {f, source} end).()
      end)
      |> Enum.map(fn {file, source} ->
        """
        ["#{file}"] = function()
          #{source}
        end,
        """
      end)
      |> Enum.join("\n")

#     IO.puts("[test] " <> replace_require("""
#     require './test'
# 
#     hello world
# 
#     require './test'
# 
#     hello world
#     """))

    final_output = """
    __modules__ = {
      #{module_list}
    }

    __cache__ = {}

    function require(idx)
      local cache = __cache__[idx]
      if cache then return cache end
      local module = __modules__[idx]()
      __cache__[idx] = module
      return module
    end

    require '#{main}'
    """

    File.write!(bundle, final_output)
		final_output
  end

  # TODO: p8 file should exist, otherwise output code bundle
	def output_p8(source, filename \\ "blah.p8") do
		{:ok, pid} = StringIO.open("")
    File.touch!(filename)

		filename
		|> File.stream!([:utf8])
		|> Stream.transform(true, fn (line, acc) ->
			case line do
				"__lua__\n" ->
					{[line], false}
				"__gfx__\n" ->
					{[source, line], true}
				_ when acc ->
					{[line], acc}
				_ when not acc ->
					{[], acc}
			end
		end)
		|> Stream.map(fn line -> IO.write(pid, line) end)
		|> Stream.run

		content = pid
			|> StringIO.flush

		File.write!(filename, content)
	end
end
