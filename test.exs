
defmodule TestError do
  defmodule File do
    def read(blah) do
      IO.puts("hello #{blah}")
    end
  end

  def test() do
    File.read("test")
  end
end

TestError.test()
