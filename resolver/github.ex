
defmodule Resolver.GitHub.InvalidPathError do
  defexception [:message]

  defp msg(path) do
    ~s(path "#{path}" is invalid, format is github.com/<user>/<repo>/<file>)
  end

  def exception(path) do
    %Resolver.GitHub.InvalidPathError{message: msg(path)}
  end
end

defmodule Resolver.GitHub.Error do
  @type t :: Resolver.GitHub.InvalidPathError | HTTPoison.Error
end

defmodule Resolver.GitHub do
  @behaviour Resolver
  @typep fetch :: (... -> %HTTPoison.Response{})
  @typep github_url :: {user :: String.t, repo :: String.t, file :: String.t}

  @doc ~S"""
  get fetches the contents for a file on GitHub.

  `path` should conform to github.com/<user>/<repo>/<file> format.

      iex> get! = fn _ ->
      ...>   %HTTPoison.Response{status_code: 200, body: "test file"}
      ...> end
      iex> Resolver.GitHub.get("github.com/nucleartide/PACK-8/file", get!)
      {:ok, "test file"}

  """
  @spec get(String.t, fetch) :: {:ok, String.t} | {:error, Error.t}
  def get(path, fetch! \\ &HTTPoison.get!/1) do
    path
    |> validate!()
    |> url()
    |> req!(fetch!)
  rescue
    e in [Resolver.GitHub.InvalidPathError, HTTPoison.Error] -> {:error, e}
  else
    result -> {:ok, result}
  end

  @doc """
  validate! that `path` conforms to the github.com/<user>/<repo>/<file>
  format.

  If validation succeeds, this function returns a tuple
  containing the user, repo, and file.

  Otherwise, this function raises a Resolver.GitHub.InvalidPathError.
  """
  @spec validate!(path :: String.t) :: github_url
  defp validate!(path) do
    parts = path
      |> Installer.normalize()
      |> String.split("/")

    case parts do
      [".", "github", "com", user, repo | file_parts]
      when length(file_parts) > 0 ->
        {user, repo, Enum.join(file_parts, "/")}
      _ ->
        raise Resolver.GitHub.InvalidPathError, path
    end
  end

  @doc """
  url returns the URL for a GitHub file.
  """
  @spec url(github_url) :: String.t
  defp url({user, repo, file}) do
    "https://raw.githubusercontent.com/#{user}/#{repo}/master/#{file}"
  end

  @doc """
  req! makes an HTTP request to a specified `url`.

  It will raise an HTTPoison.Error for responses without a
  status code of 200.
  """
  @spec req!(url :: String.t, fetch! :: fetch) :: String.t
  defp req!(url, fetch!) do
    HTTPoison.start()

    case fetch!.(url) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        body
      %HTTPoison.Response{status_code: status_code} ->
        raise HTTPoison.Error, reason: "received #{status_code} for #{url}"
    end
  end
end
