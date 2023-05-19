defmodule LatencyTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :latency_tracker,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [
        summary: [
          threshold: 85
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:gen_icmp, github: "hauleth/gen_icmp"},
      {:nimble_options, "~> 1.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
