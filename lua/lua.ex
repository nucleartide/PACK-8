defmodule Lua do
  @doc """
  Normalize a path according to Lua's `require` resolution.

  Note that Lua requires are more like Java module names, and that dots
  are replaced with path separators:

      iex> Lua.normalize("./foo/bar")
      ".///foo/bar.lua"

      iex> Lua.normalize("foo/bar")
      "./foo/bar.lua"

      iex> Lua.normalize("foo.bar")
      "./foo/bar.lua"

      iex> Lua.normalize("foo/bar.lua")
      "./foo/bar/lua.lua"

  """
  @spec normalize(path :: String.t) :: String.t
  def normalize(path) do
    path
    |> String.replace(".", "/")
    |> (fn p -> "./#{p}.lua" end).()
  end

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
