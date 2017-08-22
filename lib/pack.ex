defmodule Pack do
  def main(args) do
    args
    |> parse
    |> process
  end

  def process([]) do
    IO.puts "no args bro"
  end
  def process(options) do
    IO.puts "hello #{options[:name]}"
  end

  defp parse(args) do
    {options, _, _} = OptionParser.parse(args, switches: [foo: :string])
    options
  end
end
