
defmodule Resolver.FileSystem do
  # @behaviour Resolver

  @doc ~S"""

      iex> Resolver.FileSystem.get("project/test")
      {:ok, "-- hello world\n"}

  """
  @spec get(path :: String.t) :: {:error, any()} | {:ok, atom()}
  def get(path) do
    path
    |> Installer.normalize()
    |> File.read()
  end
end
