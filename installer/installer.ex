defmodule Installer do
  require Errors

  @doc """
  Fetch a list of dependencies in parallel.

  If any fetch fails, this function returns the error of the first
  failing fetch.
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
        {{:ok, {:ok, result}}, _dep} ->
          result
        {{:ok, {:error, reason}}, dep} ->
          {:error, Errors.wrap(reason, "failed to fetch #{dep}")}
        {{:exit, reason}, dep} ->
          {:error, Errors.wrap(reason, "failed to fetch #{dep}")}
        {nil, dep} ->
          {:error, Errors.new("failed to fetch #{dep} in time")}
      end)

    err = Enum.find(results, fn
      {:error, _} -> true
      _           -> false
    end)

    if err, do: err, else: {:ok, results}
  end

#  @doc """
#  Install parsed dependencies from a string of Lua code,
#  only if a dependency doesn't exist.
#
#      iex Installer.install("require('github.com/nucleartide/PACK-8/project/main2') require('project/testdir/bar')")
#      4
#  """
#  @spec install(lua :: String.t) :: :ok | {:error, Exception.t}
#  def install(lua) do
#    with {:ok, files} <- lua |> parse() |> fetch(),
#
#         # write _only_ remote dependencies to disk
#         files
#         |> Enum.filter(fn {path, _} -> Resolver.is_remote?(path) end)
#         |> Enum.each(fn {path, contents} ->
#           # make directories
#           path
#           |> Installer.normalize()
#           |> Path.dirname()
#           |> File.mkdir_p!()
#
#           # write to file
#           File.write!(path, contents)
#         end),
#
#         # for each file, install its dependencies too
#         Enum.each(files, fn {path, contents} ->
#           install(contents)
#         end)
#
#         do: :ok
#
#    # TODO: error handling, make this an auxiliary function
#    # TODO: handle visited files
#  end
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
