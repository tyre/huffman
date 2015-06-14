defmodule Huffman do
  alias Huffman.Tree
  import Huffman.Helpers

  @doc """
  Encodes the supplied binary, returning the encoded binary and the binary
  code => key mappings.

  Example:
    iex> {encoded, keys} = Huffman.encode "Lil Wayne is the best rapper alive."
    iex> encoded
    <<120, 78, 203, 140, 247, 7, 234, 91, 183, 29, 114, 181, 92, 94, 208, 67, 14::size(6)>>
    iex> keys
    %{<<0::size(3)>> => "i", <<2::size(4)>> => "r", <<3::size(4)>> => "s",
    <<4::size(4)>> => "l", <<5::size(4)>> => "p", <<12::size(5)>> => "W",
    <<13::size(5)>> => "b", <<14::size(5)>> => ".", <<15::size(5)>> => "L",
    <<16::size(5)>> => "v", <<17::size(5)>> => "y", <<18::size(5)>> => "h",
    <<19::size(5)>> => "n", <<10::size(4)>> => "t", <<11::size(4)>> => "a",
    <<6::size(3)>> => "e", <<7::size(3)>> => " "}
  """
  def encode(bin) do
    tree = Tree.new(byte_frequencies(bin))
    encoded = do_encode(bin, Tree.to_map(tree, :keys))
    {encoded, Tree.to_map(tree, :codes)}
  end

    defp do_encode(bin, keys) when is_map(keys) and is_binary(bin) do
      do_encode(bin, keys, <<>>)
    end

    defp do_encode(<<>>, _keys, encoded), do: encoded

    defp do_encode(<<byte::bytes-size(1), rest::binary>>, keys, encoded) do
      encoded_byte = Map.get(keys, byte)
      do_encode(rest, keys, <<encoded::bits, encoded_byte::bits>>)
    end

  @doc """
  Taking a set of keys and an encoded binary, turns it back into text.
  Example

      iex> {encoded, keys} = Huffman.encode "Lil Wayne is the best rapper alive."
      iex> Huffman.decode encoded, keys
      "Lil Wayne is the best rapper alive."
  """
  def decode(encoded, keys) do
    do_decode(encoded, keys)
  end

    def do_decode(encoded, keys) do
      tree = Tree.from_codes(Map.to_list(keys))
      do_decode(encoded, tree, <<>>)
    end

    def do_decode(<<>>, _tree, decoded), do: decoded

    def do_decode(encoded, tree, decoded) do
      {decoded_byte, rest} = Tree.get_key(tree, encoded)
      do_decode(rest, tree, decoded <> decoded_byte)
    end
end
