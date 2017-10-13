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

  def install(path) when is_binary(path) do
    with {:ok, contents} <- Resolver.get(path) do
      install_deps({path, contents})
    else
      {:error, e} -> {:error, Errors.wrap(e, "couldn't read #{path}")}
    end
  end

  @doc """
  Given a Lua file represented by `path`, install the Lua file's
  dependencies.
  """
  @spec install_deps(path :: String.t, visited :: MapSet.t) :: :ok | {:error, Exception.t}
  defp install_deps({path, contents}, visited \\ MapSet.new()) do
    deps = Lua.parse(contents)

         # fetch dependencies
    with {:ok, files} <- deps |> fetch(),

         # write _only_ remote dependencies to the file system
         :ok <- files
           |> Enum.filter(fn {path, _} -> Resolver.is_remote?(path) end)
           |> write()
    do
      # update visited map for current node
      visited = MapSet.put(visited, Lua.normalize(path))

      # for each _unvisited_ file, install its dependencies too
      Enum.reduce(files, visited, fn (f = {path, _contents}, visited) ->
        if MapSet.member?(visited, Lua.normalize(path)) do
          visited
        else
          install_deps(f, visited)
        end
      end)
    else
      {:error, e} -> {:error, Errors.wrap(e, "couldn't install deps")}
    end
  end

  # Write dependencies to file system.
  defp write(deps) do
    try do
      Enum.each(deps, fn {path, contents} ->
        # normalize path
        path = Lua.normalize(path)

        # make directories
        path
        |> Path.dirname()
        |> File.mkdir_p!()

        # write to file
        File.write!(path, contents)
      end)

      :ok
    rescue
      e in File.Error -> {:error, Errors.wrap(e, "couldn't write file")}
    end
  end
end
