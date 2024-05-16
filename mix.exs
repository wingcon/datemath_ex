defmodule DatemathEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :datemath_ex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    A parser for datemath syntax.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: "wingcon",
      licenses: ~w(MIT),
      links: %{"Github" => "https://github.com/wingcon/datemath_ex"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_parsec, "~> 1.4.0"},
      {:timex, "~> 3.7"}
    ]
  end
end
