defmodule Huffman.Mixfile do
  use Mix.Project

  def project do
    [app: :huffman,
     version: "1.1.0",
     elixir: "~> 1.0",
     source_url: "https://github.com/SenecaSystems/huffman",
     description: "Huffman encoding and decoding.",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      contributors: ["Seneca Systems"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/SenecaSystems/huffman"}
    ]
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev}
    ]
  end
end
