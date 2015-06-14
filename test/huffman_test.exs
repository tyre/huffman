defmodule HuffmanTest do
  use ExUnit.Case, async: true
  doctest Huffman

  @decoded1 "this is an example for huffman encoding"
  @encoded1 <<153, 238, 61, 199, 195, 246, 88, 128, 30, 250, 80, 247, 158, 169,
              48, 253, 44, 86, 217, 2::size(5)>>
  @keys1 %{
    <<0::size(5)>> => "p", <<1::size(5)>> => "r", <<2::size(5)>> => "g",
    <<3::size(5)>> => "l", <<1::size(3)>> => "n", <<4::size(4)>> => "m",
    <<5::size(4)>> => "o", <<12::size(5)>> => "c", <<13::size(5)>> => "d",
    <<7::size(4)>> => "h", <<8::size(4)>> => "s", <<18::size(5)>> => "x",
    <<38::size(6)>> => "t", <<39::size(6)>> => "u", <<10::size(4)>> => "f",
    <<11::size(4)>> => "i", <<12::size(4)>> => "a", <<13::size(4)>> => "e",
    <<7::size(3)>> => " "
  }

  test "encode" do
    {encoded, keys} = Huffman.encode(@decoded1)
    assert @encoded1 == encoded
    assert keys == @keys1
  end

  test "decode" do
    assert @decoded1 == Huffman.decode(@encoded1, @keys1)
  end
end
