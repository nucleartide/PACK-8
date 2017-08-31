defmodule JSONParser do
  @behaviour Parser

  def parse(str) do
  end

  def extensions() do
    ["json"]
  end
end

defmodule YAMLParser do
  @behaviour Parser

  def parse(str) do
  end

  def extensions do
    ["yml"]
  end
end
