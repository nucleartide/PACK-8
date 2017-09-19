
defmodule Installer do
  import Sigil, only: [sigil_m: 2]

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

  @doc """
  Given a list of dependencies, return a list of the
  dependencies' content.

  If fetching any dependency's content fails, this function
  will return the error of the first failing fetch.

      iex> Installer.fetch(["github.com/nucleartide/PACK-8/project/main", "project/test"])
      4

      iex> Installer.fetch(["github.com/doesnt/work", "project/test"])
      4

  """
  @spec fetch(deps :: [String.t]) :: {:ok, [String.t]} | {:error, Exception.t}
  def fetch(deps) do
    results = deps
      |> Enum.map(fn dep ->
        Task.async(fn -> Resolver.get(dep) end)
      end)
      |> Task.yield_many()
      |> Enum.map(fn {task, res} ->
        # shut down the tasks that didn't reply nor exit
        res || Task.shutdown(task, :brutal_kill)
      end)
      |> Enum.zip(deps)
      |> Enum.map(fn
        {{:ok, {:ok, result}}, dep} ->
          {dep, result}
        {{:ok, {:error, _reason} = err}, _dep} ->
          err
        {{:exit, _reason}, dep} -> # task died
          {:error, RuntimeError.exception("failed to fetch #{dep}")}
        {nil, dep} -> # task timed out
          {:error, RuntimeError.exception("failed to fetch dependency #{dep}")}
      end)

    err = Enum.find(results, fn
      {:error, _} -> true
      _           -> false
    end)

    if err, do: err, else: {:ok, results}
  end

  @doc """
  Install parsed dependencies from a string of Lua code,
  only if a dependency doesn't exist.

      iex Installer.install("require('github.com/nucleartide/PACK-8/project/main2') require('project/testdir/bar')")
      4
  """
  @spec install(lua :: String.t) :: :ok | {:error, Exception.t}
  def install(lua) do
    with {:ok, files} <- lua |> parse() |> fetch(),

         # write _only_ remote dependencies to disk
         files
         |> Enum.filter(fn {path, _} -> Resolver.is_remote?(path) end)
         |> Enum.each(fn {path, contents} ->
           # make directories
           path
           |> Installer.normalize()
           |> Path.dirname()
           |> File.mkdir_p!()

           # write to file
           File.write!(path, contents)
         end),

         # for each file, install its dependencies too
         Enum.each(files, fn {path, contents} ->
           install(contents)
         end)

         do: :ok

    # TODO: error handling, make this an auxiliary function
    # TODO: handle visited files
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
