defmodule AirQuality.MixProject do
  use Mix.Project

  def project do
    [
      app: :air_quality,
      version: "0.1.0",
      elixir: "~> 1.10.1",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [ mod: { AirQuality, [] },
      extra_applications: [:logger, :httpoison, :timex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:poison, "~> 4.0"},
      {:timex, "~> 3.6"},
      {:cowboy, "~> 2.7", only: [:test]},
      {:plug_cowboy, "~> 2.0", only: [:test]}
    ]
  end
end
