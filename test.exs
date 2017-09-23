defmodule NotError do
  defmacro wrap(exception) do
    quote do
      {unquote(exception), "#{__ENV__.file}:#{__ENV__.line}"}
    end
  end
end

defmodule Foo do
  def test do
    #Error.wrap(RuntimeError.exception("blah"))
    RuntimeError.exception("blah")
    Foo.foo()
  end

  def foo do
    raise "lol"
  end
end

defmodule Bar do
  def test do
    IO.inspect ( __ENV__.function)
    Foo.test()
  end
end

# API ===

defmodule Causer do
  @callback cause(Exception.t) :: Exception.t
end

defmodule WrappedError do
  @behaviour Causer

  defexception [:message, :env, :error]

  def cause(%WrappedError{error: error}) do
    error
  end
end

defmodule Error do
  defmacro wrap(error, message \\ "") do
    quote do
      WrappedError.exception(
        error: unquote(error),
        env: __ENV__,
        message: unquote(message)
      )
    end
  end

  def cause(error) do
    error.__struct__.cause(error)
  end
end

defmodule Program do
  require Error

  def main() do
    %RuntimeError{message: "shit"}
    |> Error.wrap("hello world")
    |> Error.cause()
    |> IO.inspect()
  end
end

Program.main()

# API ===






# (quote do: sum(1, 2, 3))
# |> IO.inspect()
# 
# (quote do: 1 + 2)
# |> IO.inspect()
# 
# [do: if(true, do: :this, else: :that)]
# |> quote()
# # |> Macro.to_string()
# |> IO.inspect()
# 
# [do: if true do :this else :that end]
# |> quote()
# # |> Macro.to_string()
# |> IO.inspect()
# 
# Macro.to_string(quote(do: 11 + unquote(number)))
# # Macro.escape # convert term (literal) to quoted expression (AST)
# # quote does the same thing
