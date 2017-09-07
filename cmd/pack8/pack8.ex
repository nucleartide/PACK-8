
defmodule Cmd.Pack8 do
  def main([]),
    do: perform("main.lua")
  def main([path]),
    do: perform(path)
  def main([path | _args]),
    do: perform(path)

  @spec perform(String.t) :: nil
  defp perform(_path) do
  end

#  def main(args) do
#     bundle = case String.ends_with?(file, ".lua") do
#       true  -> String.replace(file, ".lua", ".bundle.lua")
#       false -> throw("File #{file} does not .lua as its file extension.")
#     end
# 
#     file
#     |> Path.expand
#     |> visit
#     |> output(Path.expand(file), bundle)
#     |> output_p8(String.replace(file, ".lua", ".p8"))
#  end
end
