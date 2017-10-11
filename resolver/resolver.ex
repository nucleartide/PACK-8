defmodule Resolver do
  @doc """
  Fetch the contents of the file at `path`.
  """
  @callback get(path :: String.t) :: {:ok, String.t} | {:error, Exception.t}

  @doc """
  Delegate to implementations of the Resolver behaviour.
  """
  @spec get(path :: String.t) :: {:ok, String.t} | {:error, Exception.t}
  def get(path = "github.com/" <> _),
    do: Resolver.GitHub.get(path)
  def get(path),
    do: Resolver.FileSystem.get(path)

  @doc """
  Test if a path is a remote dependency.
  """
  @spec is_remote?(path :: String.t) :: boolean
  def is_remote?("github.com/" <> _),
    do: true
  def is_remote?(_),
    do: false
end
