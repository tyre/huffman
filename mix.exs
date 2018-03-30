defmodule Huffman.Mixfile do
  use Mix.Project

  def project do
    [
      app: :huffman,
      version: "1.2.0",
      elixir: "~> 1.6",
      source_url: "https://github.com/tyre/huffman",
      description: "Huffman encoding and decoding.",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      contributors: ["Seneca Systems"],
      maintainers: maintainers(),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tyre/huffman"}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp maintainers do
    [
      "Chris Maddox"
    ]
  end
end
