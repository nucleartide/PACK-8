
defmodule Resolver do
  @callback get(path :: String.t) :: {:ok, String.t} | {:error, any()}

  def get("github.com" <> _ = path),
    do: Resolver.GitHub.get(path)
  def get(path),
    do: Resolver.FileSystem.get(path)
end
