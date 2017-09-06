defmodule Output do
#   @doc """
#       iex> Pack8.output(MapSet.new(["/Users/jason/Repositories/pack/main.lua"]))
#       nil
# 
# 
#   """
#   def output(modules, main, bundle) do
#     list = MapSet.to_list(modules)
#     IO.inspect list
#     module_list = list
#       |> Enum.map(fn f ->
#         File.read!(f)
#         |> replace_require
#         |> (fn source -> {f, source} end).()
#       end)
#       |> Enum.map(fn {file, source} ->
#         """
#         ["#{file}"] = function()
#           #{source}
#         end,
#         """
#       end)
#       |> Enum.join("\n")
# 
#     final_output = """
#     __modules__ = {
#       #{module_list}
#     }
# 
#     __cache__ = {}
# 
#     function require(idx)
#       local cache = __cache__[idx]
#       if cache then return cache end
#       local module = __modules__[idx]()
#       __cache__[idx] = module
#       return module
#     end
# 
#     require '#{main}'
#     """
# 
#     File.write!(bundle, final_output)
# 		final_output
#   end
# 
#   # TODO: p8 file should exist, otherwise output code bundle
# 	def output_p8(source, filename \\ "blah.p8") do
# 		{:ok, pid} = StringIO.open("")
#     File.touch!(filename)
# 
# 		filename
# 		|> File.stream!([:utf8])
# 		|> Stream.transform(true, fn (line, acc) ->
# 			case line do
# 				"__lua__\n" ->
# 					{[line], false}
# 				"__gfx__\n" ->
# 					{[source, line], true}
# 				_ when acc ->
# 					{[line], acc}
# 				_ when not acc ->
# 					{[], acc}
# 			end
# 		end)
# 		|> Stream.map(fn line -> IO.write(pid, line) end)
# 		|> Stream.run
# 
# 		content = pid
# 			|> StringIO.flush
# 
# 		File.write!(filename, content)
# 	end
end
