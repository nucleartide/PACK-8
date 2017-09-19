defmodule Foo.Bar do
  # blah blah
  def hello() do
    IO.puts("inside foo.bar")
    Foo.Bar.Baz.hello()
  end
end

defmodule Foo.Bar.Baz do
  @spec hello() :: Exception.t
  def hello() do
    raise "blah"
  end
end

# Foo.Bar.hello()

opts = %{width: 10, height: 15}

with
     {:ok, width} <- Map.fetch(opts, :width),
     blah <- Foo.Bar.Baz.hello(),
     {:ok, height} <- Map.fetch(opts, :height)
do
  {:ok, width * height * blah}
else
  e ->
    IO.puts("err")
    IO.inspect(e)
end
