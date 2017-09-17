
defmodule TestError do
  defexception [:message]
    def exception(value) do
      IO.inspect(value)
      %TestError{message: "blah"}
    end
end

try do
  raise "blah"
  raise(TestError, blah: "foo", bar: "baz")
rescue
  f in [TestError, RuntimeError] -> IO.inspect(f)
end
