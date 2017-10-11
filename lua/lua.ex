defmodule Lua do
  import Sigil, only: [sigil_m: 2]

  @require ~m/
    require
    \s*
    (?<parens>\()?
      \s*
      (?<quotes>['"])
        (?<path>[^()'"]+)
      \k<quotes>
      \s*
    (?(parens)\))
  /

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

  @doc """
  Parse out `require` calls from a string of Lua code, and return their
  paths.

  See https://regex101.com/r/kzY8rx/6 for an explanation of the regex.
  Thanks to https://www.twitch.tv/jumpystick for the help!

  TODO: Make regex not transform `require` calls within comments. Doable
  with Elixir multiline modifier.

  TODO: dynamic requires? probably won't support

      iex> Lua.parse("require('foo') require('bar')")
      ["foo", "bar"]

  """
  @spec parse(lua :: String.t) :: [String.t]
  def parse(lua) do
    @require
    |> Regex.scan(lua)
    |> Enum.map(fn [_, _, _, path] -> path end)
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
