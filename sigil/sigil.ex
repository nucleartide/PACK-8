
defmodule Sigil do
  @doc """
  sigil_m is a helper for writing multi-line regexes.

  It will strip away leading and trailing whitespace for
  each line, and pass it on to the ~r sigil.
  """
  def sigil_m(string, []) do
    ~r/#{String.split(string) |> Enum.join()}/
  end
end
