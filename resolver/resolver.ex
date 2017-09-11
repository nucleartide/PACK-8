
defmodule Resolver do
  @callback get(path :: String.t) :: {:ok, String.t} | {:error, any()}
end
