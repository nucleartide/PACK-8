defmodule Lua do


#  @doc """
#  https://regex101.com/r/kzY8rx/5
#  """
#  def replace_require(lua) do
#    Regex.replace(
#      ~r/require(\s*)(\()?(\s*)(?<quote>['"])([^()'"]+)\k<quote>(?(2)(\s*)\))/,
#      lua,
#      fn _, _, _, _, _, path, ws6 ->
#        path
#        |> String.replace(".", "/")
#        |> (fn p -> "./#{p}.lua" end).()
#        |> Path.expand
#        |> (fn p -> "require '#{p}'#{ws6}" end).()
#      end
#    )
#  end
end
