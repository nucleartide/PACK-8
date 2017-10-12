defmodule Installer do
  require Errors
  require Resolver

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

    if err do
      err
    else
      {:ok, Enum.zip(deps, results)}
    end
  end

  @doc """
  Install parsed dependencies from a string of Lua code.
  """
  @spec install(lua :: String.t) :: :ok | {:error, Exception.t}
  def install(lua) do
#         # for each file, install its dependencies too
#         Enum.each(files, fn {path, contents} ->
#           install(contents)
#         end)
  end

  # Visit a file with `contents` at `path`.
  defp visit({path, contents}, visited \\ MapSet.new()) do
    deps = Lua.parse(contents)

    with {:ok, files} <- deps |> fetch() do
      # write _only_ remote dependencies to the file system
      files
      |> Enum.filter(fn {path, _} -> Resolver.is_remote?(path) end)
      |> write()

      # update visited map for current node

      # for each _unvisited_ file, install its dependencies too
    else
      {:error, e} -> {:error, Errors.wrap(e, "couldn't install deps")}
    end
  end

  # Write dependencies to file system.
  defp write(deps) do
    try do
      Enum.each(fn {path, contents} ->
        # make directories
        path
        |> Lua.normalize()
        |> Path.dirname()
        |> File.mkdir_p!()

        # write to file
        File.write!(path, contents)
      end)
    rescue
      e in File.Error -> {:error, Errors.wrap(e, "couldn't write file")}
    end
  end

# defmodule DFS do
#   def visit(start, visited \\ MapSet.new()) do
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
