
defmodule Resolver do
  @callback get(path :: String.t) :: {:ok, String.t} | {:error, any()}

  def get("github.com/" <> _ = path),
    do: Resolver.GitHub.get(path)
  def get(path),
    do: Resolver.FileSystem.get(path)

  @doc "Test if a path is a remote dependency."
  def is_remote?("github.com/" <> _),
    do: true
  def is_remote?(_),
    do: false
end
