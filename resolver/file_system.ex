defmodule Resolver.FileSystem do
  require Lua
  require Errors

  @behaviour Resolver

  @doc ~S"""
  Get a Lua file from the file system.

      iex> Resolver.FileSystem.get("project/test")
      {:ok, "-- hello world\n"}

  """
  @spec get(path :: String.t) :: {:ok, String.t} | {:error, Exception.t}
  def get(path) do
    res = path
      |> Lua.normalize()
      |> File.read()

    with {:ok, _} <- res do
      res
    else
      {:error, e} -> {:error, Errors.wrap(e, "couldn't open file")}
    end
  end
end
