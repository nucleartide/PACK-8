
defmodule Parser do
  @callback parse(String.t) :: any
  @callback extensions() :: [String.t]
end
