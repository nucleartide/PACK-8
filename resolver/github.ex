
defmodule Resolver.GitHub do
  @behaviour Resolver

  @doc ~S"""

      iex> Resolver.GitHub.get("github.com/nucleartide/PACK-8/project/main")
      {:ok, "\n-- https://stackoverflow.com/questions/36126249/no-parentheses-after-a-function-name\nrequire './testdir/bar'\nrequire './testdir/foo'\n"}

  """
  def get("github.com" <> _ = path) do
    path
    |> Installer.normalize()
    |> String.split("/")
    |> url()
    |> wrap(&req/1)
  end

  defp url([".", "github", "com", user, repo | file_parts]) do
    file = Enum.join(file_parts, "/")
    {:ok, "https://raw.githubusercontent.com/#{user}/#{repo}/master/#{file}"}
  end

  defp url(parts) do
    {:error, {:malformed_url, parts}}
  end

  defp wrap(input, func) do
    case input do
      {:ok, result} -> func.(result)
      {:error, _} -> input
    end
  end

  defp req(url) do
    res = Tesla.get(url)

    case res.status do
      200 -> {:ok, res.body}
      404 -> {:error, :not_found}
      _   -> {:error, {:status_code, res.status}}
    end
  end
end
