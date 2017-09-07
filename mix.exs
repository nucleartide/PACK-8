defmodule Pack8.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pack8,
      version: "0.1.0",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: [main_module: Main],
      test_paths: ["."],
      elixirc_paths: File.ls!()
       |> Enum.filter(fn path -> File.dir?(path) end)
       |> Enum.filter(fn path -> not Enum.member?([".git", "_build", "deps"], path) end)
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      # doesn't work with "../pack8"
      {:fs, "2.12.0"}, # doesn't work with new compile paths :(
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
    ]
  end
end
