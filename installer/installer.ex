# walk lua file's dependency tree
# ensure all files are available locally

# packages:
# installer, however two resolvers are needed
# bundler

defmodule Installer do
  import Sigil, only: [sigil_m: 2]

  @doc """
  blah blah
  """
  @require ~m/
    require
    \s*
    (?<parens>\()?
      \s*
      (?<quotes>['"])
        (?<path>[^()'"]+)
      \k<quotes>
      \s*
    (?(parens)\))
  /

  @doc """
  Parse out `require` calls from a string of Lua code, and
  return their paths.

  See https://regex101.com/r/kzY8rx/6 for an explanation of
  the regex. Thanks to https://www.twitch.tv/jumpystick for
  the help!

  TODO: Make regex not transform `require` calls within
  comments. Doable with Elixir multiline modifier.

      iex> Installer.parse("require('foo') require('bar')")
      ["foo", "bar"]

  """
  @spec parse(String.t) :: [String.t]
  def parse(lua) do
    @require
    |> Regex.scan(lua)
    |> Enum.map(fn [_, _, _, path] -> path end)
  end

  @doc """
  Normalize a path according to Lua's `require` resolution.

  Note that Lua requires are more like Java module names,
  and that dots are replaced with path separators:

      iex> Installer.normalize("./foo/bar")
      ".///foo/bar.lua"

      iex> Installer.normalize("foo/bar")
      "./foo/bar.lua"

      iex> Installer.normalize("foo.bar")
      "./foo/bar.lua"

      iex> Installer.normalize("foo/bar.lua")
      "./foo/bar/lua.lua"

  """
  def normalize(path) do
    path
    |> String.replace(".", "/")
    |> (fn p -> "./#{p}.lua" end).()
  end

  @doc """
  Install parsed dependencies from a string of Lua code.
  """
  @spec install(String.t) :: {:ok} | {:error}
  def install(lua) do
    parse(lua)

    {:ok}
  end
end

defmodule DFS do
#   @doc """
#   Perform a DFS traversal of a Lua file's dependency tree.
# 
#   TODO: make resolver / installer like in TJ's mmake?
# 
#       iex> Pack8.visit("/Users/jason/Repositories/pack/main.lua").map
#       %{"/Users/jason/Repositories/pack/main.lua" => true, "/Users/jason/Repositories/pack/test_module.lua" => true}
# 
#   """
#   def visit(start, visited \\ MapSet.new()) do
#     a = cond do
#       File.regular?(start) ->
#         "blah"
#       String.starts_with?(start, "github.com") ->
#         "blah"
#       true ->
#         "throw error"
#     end
#     IO.puts(a)
# 
#     adj = start
#       |> File.read!
#       |> parse_requires
#     acc = visited |> MapSet.put(start)
# 
#     Enum.reduce(adj, acc, fn (n, acc) ->
#       n = lua_require(n)
#       new_acc = case MapSet.member?(acc, n) do
#         true  -> acc
#         false -> visit(n, acc)
#       end
#     end)
#   end
end
