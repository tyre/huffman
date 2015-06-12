defmodule Huffman do
  alias Huffman.Tree
  import Huffman.Helpers

  def encode(bin) do
    tree = Tree.new(byte_frequencies(bin))
    encoded = do_encode(bin, Tree.to_map(tree, :keys))
    {encoded, Tree.to_map(tree, :codes), tree}
  end

  def decode(encoded, keys) do
    do_decode(encoded, keys)
  end

  defp do_encode(bin, keys) when is_map(keys) and is_binary(bin) do
    do_encode(bin, keys, <<>>)
  end

  defp do_encode(<<>>, _keys, encoded), do: encoded

  defp do_encode(<<byte::bytes-size(1), rest::binary>>, keys, encoded) do
    encoded_byte = Map.get(keys, byte)
    do_encode(rest, keys, <<encoded::bits, encoded_byte::bits>>)
  end

  def do_decode(encoded, keys) do
    tree = Tree.from_codes(Map.to_list(keys))
    do_decode(encoded, tree, <<>>)
  end

  def do_decode(<<>>, _tree, decoded), do: decoded

  def do_decode(encoded, tree, decoded) do
    {code, decoded_byte} = Tree.get_key(tree, encoded)
    code_length = bit_size(code)
    IO.puts("Code (#{bit_size(code)}): #{inspect(code)}")
    <<^code::bits-size(code_length), rest::bits>> = encoded
    IO.puts "Decoded #{decoded_byte}"
    IO.puts("rest: " <> inspect(rest))
    do_decode(rest, tree, decoded <> decoded_byte)
  end
end
