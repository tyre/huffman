defmodule Huffman.Helpers do
  @doc """
  Counts the frequency of bytes in a given binary.

  Returns a list of tuples, the first element is the byte and the second
  is the number of occurences. The list is sorted first by the count, falling
  back to comparing the bytes themselves.

      iex> Huffman.Helpers.byte_frequencies("bobbing")
      [{"g", 1}, {"i", 1}, {"n", 1}, {"o", 1}, {"b", 3}]
  """
  def byte_frequencies(<<bin::binary>>) do
    byte_frequencies(bin, %{})
    |> Enum.to_list
    |> Enum.sort(&sort_frequencies/2)
  end

  defp byte_frequencies(<<>>, frequency_map) do
    frequency_map
  end

  defp byte_frequencies(<<byte::binary-size(1), rest::binary>>, frequency_map) do
    new_frequency_map = Dict.update(frequency_map, byte, 1, fn
      (count) -> count + 1
    end)
    byte_frequencies(rest, new_frequency_map)
  end

  def sort_frequencies({_byte1, count1}, {_byte2, count2}) when count1 < count2,
    do: true
  def sort_frequencies({_byte1, count1}, {_byte2, count2}) when count1 > count2,
    do: false
  def sort_frequencies({byte1, _count1}, {byte2, _count2}) when byte1 < byte2,
    do: true
  def sort_frequencies({byte1, _count1}, {byte2, _count2}) when byte1 > byte2,
    do: false
end
