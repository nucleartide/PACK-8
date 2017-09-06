defmodule Lua do
  @doc """
  https://regex101.com/r/kzY8rx/5
  """
  def replace_require(lua) do
    Regex.replace(
      ~r/require(\s*)(\()?(\s*)(?<quote>['"])([^()'"]+)\k<quote>(?(2)(\s*)\))/,
      lua,
      fn _, _, _, _, _, path, ws6 ->
        path
        |> String.replace(".", "/")
        |> (fn p -> "./#{p}.lua" end).()
        |> Path.expand
        |> (fn p -> "require '#{p}'#{ws6}" end).()
      end
    )
  end

  @doc """
  Given a string of Lua code, parse out `require` calls and
  return a list of required paths.

  See https://regex101.com/r/kzY8rx/4 for an explanation of
  the regex. (Thanks to https://www.twitch.tv/jumpystick.)
  """
  def parse_requires(lua) do
    ~r/require\s*(\()?\s*(?<quote>['"])([^()'"]+)\k<quote>\s*(?(1)\))/
    |> Regex.scan(lua)
    |> Enum.map(fn [_, _, _, match] -> match end)
  end

  @doc """
  Normalize a path according to Lua's `require` resolution.

  Note that Lua requires are more like Java module names,
  and that dots are replaced with path separators:

    './foo/bar'   -> './foo/bar.lua'
    'foo/bar'     -> './foo/bar.lua'
    'foo.bar'     -> './foo/bar.lua'
    'foo/bar.lua' -> './foo/bar/lua.lua'
  """
  def lua_require(module_path) do
    module_path
    |> String.replace(".", "/")
    |> (fn p -> "./#{p}.lua" end).()
    |> Path.expand
  end
end
