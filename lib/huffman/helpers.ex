defmodule Huffman.Helpers do

  @doc """
  Returns all codepoints in the string. Optional second argument specifies the
  encoding (utf8, utf16, utf32), defaulting to `:utf8`.

  ## Examples

      iex> Huffman.Helpers.codepoints(<<"boom"::utf8>>, :utf8)
      [<<98>>, <<111>>, <<111>>, <<109>>]

      iex> Huffman.Helpers.codepoints(<<"boom"::utf16>>, :utf16)
      [<<0, 98>>, <<0, 111>>, <<0, 111>>, <<0, 109>>]

      iex> Huffman.Helpers.codepoints(<<"boom"::utf32>>, :utf32)
      [<<0, 0, 0, 98>>, <<0, 0, 0, 111>>, <<0, 0, 0, 111>>, <<0, 0, 0, 109>>]

  """
  def codepoints(binary, encoding\\:utf8)
  def codepoints(binary, encoding) when is_binary(binary) do
    do_codepoints(next_codepoint(binary, encoding), encoding)
  end

  defp do_codepoints({c, rest}, encoding) do
    [c|do_codepoints(next_codepoint(rest, encoding), encoding)]
  end

  defp do_codepoints(nil, _encoding) do
    []
  end

  @doc """
  Returns the next codepoint in a String. Optional second argument specifies the
  encoding (utf8, utf16, utf32), defaulting to `:utf8`.

  ## Examples

      iex> Huffman.Helpers.next_codepoint("olá")
      {"o", "lá"}

      iex> Huffman.Helpers.next_codepoint(<<"olá"::utf16>>, :utf16)
      {<<0, 111>>, <<0, 108, 0, 225>>}

      iex> Huffman.Helpers.next_codepoint(<<"olá"::utf32>>, :utf32)
      {<<0, 0, 0, 111>>, <<0, 0, 0, 108, 0, 0, 0, 225>>}
  """
  def next_codepoint(bin, encoding\\:utf8)
  def next_codepoint(<< cp :: utf8, rest :: binary >>, :utf8) do
    {<<cp :: utf8>>, rest}
  end

  def next_codepoint(<< cp :: utf16, rest :: binary >>, :utf16) do
    {<<cp :: utf16>>, rest}
  end

  def next_codepoint(<< cp :: utf32, rest :: binary >>, :utf32) do
    {<<cp :: utf32>>, rest}
  end

  def next_codepoint(<< cp, rest :: binary >>, _encoding) do
    {<<cp>>, rest}
  end

  def next_codepoint(<<>>, _encoding) do
    nil
  end

  @doc """
  Counts the frequency of codepoints in a given binary.

  Returns a list of tuples, the first element is the code point and the second
  is the number of occurences. The list is sorted first by the count, falling
  back to comparing the codepoints themselves.

      iex> Huffman.Helpers.binary_frequencies("bobbing")
      [{"g", 1}, {"i", 1}, {"n", 1}, {"o", 1}, {"b", 3}]

  Defaults to utf8 but the optional second parameter can also be set to `:utf16`
  or `:utf32`
  """
  def binary_frequencies(bin, encoding\\:utf8)
  def binary_frequencies(bin, encoding) do
    do_binary_frequencies(bin, encoding)
    |> Enum.to_list
    |> Enum.sort(&sort_frequencies/2)
  end

  defp do_binary_frequencies(bin, encoding) when is_binary(bin) and is_atom(encoding) do
    count_frequencies(codepoints(bin, encoding), %{})
  end

  defp count_frequencies([], frequency_map) do
    frequency_map
  end

  defp count_frequencies([head|tail], frequency_map) do
    count_frequencies(tail, increment(frequency_map, head))
  end

  defp increment(frequency_map, binary_codepoint) do
    Dict.update(frequency_map, binary_codepoint, 1, fn
      (count) -> count + 1
    end)
  end

  def sort_frequencies({_byte1, count1}, {_byte2, count2}) when count1 < count2,
    do: true
  def sort_frequencies({_byte1, count1}, {_byte2, count2}) when count1 > count2,
    do: false
  def sort_frequencies({byte1, _count1}, {byte2, _count2}) when byte1 < byte2,
    do: true
  def sort_frequencies({byte1, _count1}, {byte2, _count2}) when byte1 > byte2,
    do: false

  def inspect_bits(bits) do
    bit_string = accumulate_bits(bits)
      |> Enum.map(fn (bit) -> "#{bit}::1" end)
      |> Enum.join(", ")
    "<<#{bit_string}>>"
  end

  defp accumulate_bits(bits) do
    accumulate_bits(bits, [])
  end

  defp accumulate_bits(<<>>, bits) do
    Enum.reverse bits
  end

  defp accumulate_bits(<<bit::integer-size(1)-unit(1), rest::bits>>, acc) do
    accumulate_bits(rest, [inspect(bit) | acc])
  end
end
