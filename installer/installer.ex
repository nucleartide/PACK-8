# walk lua file's dependency tree
# ensure all files are available locally

# packages:
# installer, however two resolvers are needed
# bundler

defmodule Installer do
  @doc "parse installs parsed dependencies from a Lua file."
  @spec parse(String.t) :: nil
  def parse(lua) do
  end
end

defmodule DFS do
#   @doc """
#   Perform a DFS traversal of a Lua file's dependency tree.
# 
#   TODO: make resolver / installer like in TJ's mmake?
# 
#       iex> Pack8.visit("/Users/jason/Repositories/pack/main.lua").map
#       %{"/Users/jason/Repositories/pack/main.lua" => true, "/Users/jason/Repositories/pack/test_module.lua" => true}
# 
#   """
#   def visit(start, visited \\ MapSet.new()) do
#     a = cond do
#       File.regular?(start) ->
#         "blah"
#       String.starts_with?(start, "github.com") ->
#         "blah"
#       true ->
#         "throw error"
#     end
#     IO.puts(a)
# 
#     adj = start
#       |> File.read!
#       |> parse_requires
#     acc = visited |> MapSet.put(start)
# 
#     Enum.reduce(adj, acc, fn (n, acc) ->
#       n = lua_require(n)
#       new_acc = case MapSet.member?(acc, n) do
#         true  -> acc
#         false -> visit(n, acc)
#       end
#     end)
#   end
end
