defmodule HuffmanTest do
  use ExUnit.Case, async: true
  import Huffman.Helpers

  @decoded1 "this is an example for huffman encoding"
  @encoded1 <<103, 180, 126, 143, 57, 237, 38, 64, 197, 245, 168, 126, 229, 84,
              142, 123, 134, 171, 108, 8::size(5)>>
  @keys1 %{
    <<0::size(5)>> => "p", <<1::size(4)>> => "s", <<2::size(4)>> => "m",
    <<3::size(4)>> => "a", <<6::size(5)>> => "c", <<8::size(5)>> => "g",
    <<9::size(5)>> => "x", <<5::size(4)>> => "f", <<25::size(6)>> => "t",
    <<4::size(3)>> => "n", <<16::size(5)>> => "r", <<10::size(4)>> => "o",
    <<11::size(4)>> => "e", <<22::size(5)>> => "d", <<24::size(5)>> => "l",
    <<13::size(4)>> => "i", <<7::size(3)>> => " ", <<14::size(4)>> => "h",
    <<57::size(6)>> => "u"
  }

  test "frequencies" do

  end

  test "encode" do
    {encoded, keys, tree} = Huffman.encode(@decoded1)
    assert tree == Huffman.Tree.new(byte_frequencies(@decoded1))
    assert keys == @keys1
    assert @encoded1 == encoded
  end

  test "decode" do
    decoded = Huffman.decode(@encoded1, @keys1)
    IO.puts(decoded)
  end
end
