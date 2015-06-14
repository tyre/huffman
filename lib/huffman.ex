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

  It encodes based on utf8 codepoints by default:

      iex> Huffman.encode("ƒøßª™º£:")
      {<<159, 10, 90>>,
      %{<<0::size(3)>> => "ª", <<1::size(3)>> => "º", <<2::size(3)>> => ":", <<3::size(3)>> => "£", <<4::size(3)>> => "ƒ",
        <<5::size(3)>> => "™", <<6::size(3)>> => "ß", <<7::size(3)>> => "ø"}}

  But you can also specify utf16 or utf32:

      iex> Huffman.encode(<<"bananas"::utf16>>, :utf16)
      {<<141, 21::size(5)>>,
       %{<<0::size(1)>> => <<0, 97>>, <<4::size(3)>> => <<0, 98>>,
         <<5::size(3)>> => <<0, 115>>, <<3::size(2)>> => <<0, 110>>}}

      iex> Huffman.encode(<<"bananas"::utf32>>, :utf32)
      {<<141, 21::size(5)>>,
      %{<<0::size(1)>> => <<0, 0, 0, 97>>, <<4::size(3)>> => <<0, 0, 0, 98>>,
      <<5::size(3)>> => <<0, 0, 0, 115>>, <<3::size(2)>> => <<0, 0, 0, 110>>}}


  """
  def encode(bin, encoding\\:utf8)
  def encode(bin, encoding) do
    tree = Tree.new(binary_frequencies(bin, encoding))
    keys_to_codes = Tree.to_map(tree, :keys)
    encoded = encode_codepoints(codepoints(bin, encoding), keys_to_codes)
    {encoded, Tree.to_map(tree, :codes)}
  end

    defp encode_codepoints(codepoints, keys) do
      encode_codepoints(codepoints, keys, <<>>)
    end

    defp encode_codepoints([], _keys, encoded), do: encoded

    defp encode_codepoints([codepoint | tail], keys, encoded) do
      encoded_byte = Map.get(keys, codepoint)
      encode_codepoints(tail, keys, <<encoded::bits, encoded_byte::bits>>)
    end

  @doc """
  Taking a set of keys and an encoded binary, turns it back into text.
  Example

      iex> {encoded, keys} = Huffman.encode "Lil Wayne is the best rapper alive."
      iex> Huffman.decode encoded, keys
      "Lil Wayne is the best rapper alive."

  Note that decoding will return the same utf encoding as what `Huffman.encode`
  was given:

      iex> {encoded, keys} = Huffman.encode(<<"bananas"::utf32>>, :utf32)
      iex> Huffman.decode(encoded, keys)
      <<0, 0, 0, 98, 0, 0, 0, 97, 0, 0, 0, 110, 0, 0, 0, 97, 0, 0, 0, 110, 0, 0, 0, 97, 0, 0, 0, 115>>
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
