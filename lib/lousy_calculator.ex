defmodule LousyCalculator do
  @typedoc """
  just a number followed by a string.
  """
  @type number_with_remark :: {number, String.t}

  @spec add(number, number) :: number_with_remark
  def add(x, y) do
    {x + y, "you need a calculator to do that?"}
  end

  @spec multiply(number, number) :: number_with_remark
  def multiply(x, y) do
    {x * y, "wtf"}
  end
end
