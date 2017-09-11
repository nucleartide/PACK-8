
defmodule Resolver.FileSystem do
  # @behaviour Resolver

  @doc ~S"""

      iex> Resolver.FileSystem.get("test_helper.exs")
      {:ok, "ExUnit.start()\n"}

  """
  @spec get(path :: String.t) :: {:error, any()} | {:ok, atom()}
  def get(path) do
    File.read(path)
  end
end
