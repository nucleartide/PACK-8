defmodule Pack8.Mixfile do
  use Mix.Project

  def project do
    [app: :pack8,
     version: "0.1.0",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     escript: [main_module: Cmd.Pack8],
     test_paths: ["."],
     elixirc_paths: File.ls!()
       |> Enum.filter(&File.dir?(&1))
       |> Enum.filter(&not Enum.member?([".git", "_build", "deps"], &1))]
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
    [{:fs, "2.12.0"},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false}]
  end
end

IO.inspect(Mix.Project.load_paths)
