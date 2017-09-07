
defmodule Main do
  # TODO: improve help output
  def main([]),
    do: IO.puts(:stderr, "Must specify a filename.")
  def main([path]),
    do: perform(path)
  def main([path | _args]),
    do: perform(path)

  @spec perform(String.t) :: nil
  defp perform(_path) do
  end

#  def main(args) do
#     file
#     |> Path.expand
#     |> visit
#     |> output(Path.expand(file), bundle)
#     |> output_p8(String.replace(file, ".lua", ".p8"))
#  end
end
