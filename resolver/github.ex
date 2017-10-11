# defmodule Resolver.GitHub.PathError do
#   defexception [:message]
# 
#   defp msg(path) do
#     ~s(path "#{path}" is invalid, format is github.com/<user>/<repo>/<file>)
#   end
# 
#   def exception(path) do
#     %Resolver.GitHub.PathError{message: msg(path)}
#   end
# end

# defmodule Resolver.GitHub.Error do
#   @type t :: PathError | HTTPoison.Error
# end

defmodule Resolver.GitHub do
  @behaviour Resolver
  @typep fetch :: (... -> %HTTPoison.Response{})
  @typep github_url :: {user :: String.t, repo :: String.t, file :: String.t}

  @doc ~S"""
  get fetches the contents for a file on GitHub.

  `path` should conform to github.com/<user>/<repo>/<file> format.

      iex> get = fn _ ->
      ...>   {:ok, %HTTPoison.Response{status_code: 200, body: "test file"}}
      ...> end
      iex> Resolver.GitHub.get("github.com/nucleartide/PACK-8/file", get)
      {:ok, "test file"}

      iex> Resolver.GitHub.get("this isn't github wtf")
      {:error, %Resolver.GitHub.PathError{message: "path \"this isn't github wtf\" is invalid, format is github.com/<user>/<repo>/<file>"}}

      iex> get = fn _ ->
      ...>   {:ok, %HTTPoison.Response{status_code: 404}}
      ...> end
      iex> Resolver.GitHub.get("github.com/nucleartide/PACK-8/file", get)
      {:error, %HTTPoison.Error{reason: "received 404 for https://raw.githubusercontent.com/nucleartide/PACK-8/master/file.lua"}}

  """
  @spec get(String.t, fetch) :: {:ok, String.t} | {:error, Error.t}
  def get(path, fetch \\ &HTTPoison.get/1) do
    with {:ok, github_url} <- validate(path),
         {:ok, content}    <- github_url |> url() |> req(fetch),
         do: {:ok, content}
  end

  # Validate that `path` conforms to the github.com/<user>/<repo>/<file>
  # format.
  # 
  # If validation succeeds, this function returns a tuple containing the
  # user, repo, and file.
  # 
  # Else, this function returns a Resolver.GitHub.PathError.
  @spec validate(path :: String.t) :: {:ok, github_url} | {:error, Exception.t}
  defp validate(path) do
    parts = path
      |> Installer.normalize()
      |> String.split("/")

    case parts do
      [".", "github", "com", user, repo | file] when length(file) > 0 ->
        {:ok, {user, repo, Enum.join(file, "/")}}
      _ ->
        {:error, Resolver.GitHub.PathError.exception(path)}
    end
  end

  # url returns the URL for a GitHub file.
  @spec url(github_url) :: String.t
  defp url({user, repo, file}) do
    "https://raw.githubusercontent.com/#{user}/#{repo}/master/#{file}"
  end

  # req makes an HTTP request to a specified `url`.
  #
  # It will return an HTTPoison.Error for responses without a status
  # code of 200.
  @spec req(String.t, fetch) :: {:ok, String.t} | {:error, Exception.t}
  defp req(url, fetcher) do
    HTTPoison.start()

    case fetcher.(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        reason = "received #{status_code} for #{url}"
        {:error, %HTTPoison.Error{reason: reason}}
      err ->
        err
    end
  end
end
