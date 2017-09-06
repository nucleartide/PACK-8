defmodule HTTP do
  def get do
    Application.ensure_all_started(:inets)
    :ssl.start()

    {:ok, res} = :httpc.request(:get, {'https://raw.githubusercontent.com/tj/make/master/golang.mk', []}, [], [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = res

    IO.write(body)
  end
end
