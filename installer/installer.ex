
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

  TODO: dynamic requires, won't support

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
  @spec normalize(path :: String.t) :: String.t
  def normalize(path) do
    path
    |> String.replace(".", "/")
    |> (fn p -> "./#{p}.lua" end).()
  end

  @spec fetch(deps :: [String.t]) :: any()
  defp fetch(deps) do
    deps
    |> Enum.map(&Resolver.get/1)
  end

  @doc """
  Install parsed dependencies from a string of Lua code,
  only if a dependency doesn't exist.

  Note: this function has side effects.

      iex> Installer.install("require('github.com/nucleartide/PACK-8/project/main2') require('project/testdir/bar')")
      4
  """
  @spec install(lua :: String.t) :: :ok | {:error, any()}
  def install(lua) do
    lua
    |> parse # grab list of dependencies

    # grab the contents of each dependency in parallel
    # if some dependencies can't be fetched, the error of the first failed dep
    # will be returned

    # TODO: add this code in

    # ===
    # ===
    # ===

    # convert list of dependencies to list of file paths
    # file_paths = deps |> Enum.map(&Installer.normalize/1)

    # list of remote dependencies
    deps = parse(lua)
     |> Enum.filter(fn
       "github.com" <> _ = path -> true
       _ -> false
     end)

    # list of dependencies, converted to list of file paths
    normalized = deps
      |> Enum.map(&Installer.normalize/1)

    # list of file contents
    file_contents = deps
      |> Enum.map(&Resolver.get/1)
      |> Enum.map(&handle_error/1)

    for {path, contents} <- Enum.zip(normalized, file_contents) do
      # make directories
      path
      |> Path.dirname()
      |> File.mkdir_p!()

      # write to file
      File.write(path, contents)

      # install this file's dependencies too
      install(contents)
    end
  end

  defp handle_error({:ok, result}) do
    result
  end
  defp handle_error({:error, reason}) do
    raise("fail")
  end
end

# defmodule DFS do
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
# end
