
defmodule Test do
  def is_remote?(4),
    do: true
  def is_remote?(_),
    do: false
end

a = 4
case a do
  a when Test.is_remote?(a) ->
    "success"
end
