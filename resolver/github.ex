defmodule Resolver.GitHub do
  require Lua
  require Errors

  @behaviour Resolver
  @typep github_url :: {user :: String.t, repo :: String.t, file :: String.t}

  @doc ~S"""
  Fetch the contents for a file on GitHub.

  Note that `path` should conform to github.com/<user>/<repo>/<file>
  format.
  """
  @spec get(path :: String.t) :: {:ok, String.t} | {:error, Exception.t}
  def get(path) do
    with {:ok, github_url} <- validate(path),
         res = {:ok, _}    <- github_url |> url() |> req() do
      res
    else
      {:error, e} -> {:error, Errors.wrap(e, "couldn't fetch github file")}
    end
  end

  # url returns the URL for a GitHub file.
  @spec url(github_url) :: String.t
  defp url({user, repo, file}) do
    "https://raw.githubusercontent.com/#{user}/#{repo}/master/#{file}"
  end

  # Validate that `path` conforms to the github.com/<user>/<repo>/<file>
  # format.
  @spec validate(path :: String.t) :: {:ok, github_url} | {:error, Exception.t}
  defp validate(path) do
    parts = path
      |> Lua.normalize()
      |> String.split("/")

    case parts do
      [".", "github", "com", user, repo | file] when length(file) > 0 ->
        {:ok, {user, repo, Enum.join(file, "/")}}
      _ ->
        {:error, path |> invalid_msg() |> Errors.new()}
    end
  end

  @spec invalid_msg(path :: String.t) :: String.t
  defp invalid_msg(path) do
    ~s(#{path} is invalid, format is github.com/<user>/<repo>/<file>)
  end

  # req makes an HTTP request to a specified `url`.
  #
  # It will return an HTTPoison.Error for responses without a status
  # code of 200.
  @spec req(url :: String.t) :: {:ok, String.t} | {:error, Exception.t}
  defp req(url) do
    HTTPoison.start()

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, Errors.new("received #{status_code} for #{url}")}
      {:error, e} ->
        {:error, Errors.wrap(e, "http request failed")}
    end
  end
end
