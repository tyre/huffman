defmodule Huffman.Tree do
  alias __MODULE__, as: Tree
  alias Huffman.Tree.Node

  defstruct root: %Node{}


  def new([]) do
    %Tree{}
  end

  @doc """
    Creates a new huffman tree withthe included frequencies

      iex> Huffman.Tree.new([{"a", 1}, {"b", 1}, {"c", 4}, {"x", 9}])
      %Huffman.Tree{root: %Huffman.Tree.Node{code: "", key: nil,
        left: %Huffman.Tree.Node{code: <<0::size(1)>>, key: nil,
         left: %Huffman.Tree.Node{code: <<0::size(2)>>, key: nil,
          left: %Huffman.Tree.Node{code: <<0::size(3)>>, key: nil, left: nil,
           right: nil, weight: 1},
          right: %Huffman.Tree.Node{code: <<4::size(3)>>, key: nil, left: nil,
           right: nil, weight: 1}, weight: 2},
         right: %Huffman.Tree.Node{code: <<2::size(2)>>, key: nil, left: nil,
          right: nil, weight: 4}, weight: 6},
        right: %Huffman.Tree.Node{code: <<1::size(1)>>, key: nil, left: nil,
         right: nil, weight: 9}, weight: 15}}
  """
  def new(frequencies) do
    leaf_nodes(frequencies)
    |> build(new([]))
  end

  @doc """
  Takes a list of codes and their corresponding bytes, rebuilding the tree (
  without weights)
  """
  def from_codes(codes) do
    sorted_codes = Enum.sort_by(codes, &elem(&1, 0), &code_sorter/2)
    IO.puts inspect sorted_codes
    do_from_codes(%Tree{}, sorted_codes)
  end

  defp code_sorter(code1, code2) when bit_size(code1) > bit_size(code2), do: false
  defp code_sorter(code1, code2) when bit_size(code1) < bit_size(code2), do: true
  defp code_sorter(<<0::1, _rest1::bits>>, <<1::1, rest2::bits>>), do: true
  defp code_sorter(<<1::1, _rest1::bits>>, <<0::1, rest2::bits>>), do: false
  defp code_sorter(<<_bit1::1, code1::bits>>, <<_bit2::1, code2::bits>>) do
    code_sorter(code1, code2)
  end

  def to_map(%Tree{}=tree) do
    to_map(tree, :codes)
  end

  def to_map(%Tree{}=tree, :codes) do
    reduce(tree, %{}, fn (%Node{key: key, code: code}, acc) ->
      Map.put(acc, code, key)
    end)
  end

  def to_map(%Tree{}=tree, :keys) do
    reduce(tree, %{}, fn (%Node{key: key, code: code}, acc) ->
      Map.put(acc, key, code)
    end)
  end

  def to_list(%Tree{}=tree) do
    reduce(tree, [], fn (%Node{key: key, code: code}, acc) ->
      [{key, code} | acc]
    end)
  end

  def get_key(%Tree{root: root}=tree, key_bits) when is_bitstring(key_bits) do
    do_get_key(key_bits, root)
  end

  defp do_get_key(_key_bits, %Node{left: nil, right: nil, key: key, code: code}) do
    {code, key}
  end

  defp do_get_key(<<0::1, _rest::bits>>, %Node{left: left, key: key, code: code}) when is_nil(left) do
    {code, key}
  end

  defp do_get_key(
    <<1::1, _rest::bits>>,
    %Node{right: right, key: key, code: code})
  when is_nil(right)
  do
    {code, key}
  end

  defp do_get_key(<<0::1, rest::bits>>, %Node{left: left}) when not is_nil(left) do
    do_get_key(rest, left)
  end

  defp do_get_key(<<1::1, rest::bits>>, %Node{right: right}) when not is_nil(right) do
    do_get_key(rest, right)
  end

  @doc """
    calls the supplied function for each leaf node.
  """
  def reduce(%Tree{root: root}, acc, fun) do
    do_reduce(root, acc, fun)
  end

  def build([], %Tree{}=tree) do
    tree
  end

  def build([%Node{}=node], %Tree{root: root}=tree) do
    %Tree{tree| root: Node.combine(node, root)}
    |> recode
  end

  def build(
    [%Node{}=node1, %Node{}=node2|tail],
    %Tree{}=tree)
  do
    combined_node = Node.combine(node1, node2)
    sorted_nodes([combined_node|tail])
    |> build(tree)
  end

  defp leaf_nodes(frequencies),
    do: leaf_nodes(frequencies, [])

  defp leaf_nodes([], acc),
    do: Enum.reverse(acc)

  defp leaf_nodes([{code, weight} | tail], acc) do
    new_acc = [Node.new(weight, code) | acc]
    leaf_nodes(tail, new_acc)
  end

  defp sorted_nodes(nodes) do
    weight_mapper = fn (%Node{weight: weight}) -> weight end
    Enum.sort_by(nodes, weight_mapper)
  end

  defp recode(%Tree{root: root}=tree) do
    %Tree{tree | root: recode(root, <<>>) }
  end

  defp recode(nil, _code), do: nil

  defp recode(%Node{left: nil, right: nil}=node, code) do
    %Node{node | code: code }
  end

  defp recode(%Node{left: left, right: right}=node, code) do
    %Node{
      node |
      code: code,
      left: recode(left, <<0::size(1), code::bits>>),
      right: recode(right, <<1::size(1), code::bits>>)
    }
  end

  def insert(%Tree{root: root}, code, <<key::binary-size(1)>>) when is_bitstring(code) do
    %Tree{root: do_insert(code, code, key, root)}
  end

  defp do_insert(<<0::1>>, code, key , %Node{}=node) do
    %Node{node | left: %Node{code: code, key: key}}
  end

  defp do_insert(<<1::1>>, code, key , %Node{}=node) do
    %Node{node | right: %Node{code: code, key: key}}
  end

  defp do_insert(<<0::1, rest::bits>>, code, key, %Node{left: left}=node) do
    %Node{ node | left: do_insert(rest, code, key, left || %Node{})}
  end

  defp do_insert(<<1::1, rest::bits>>, code, key, %Node{right: right}=node) do
    %Node{ node | right: do_insert(rest, code, key, right || %Node{})}
  end

  defp do_from_codes(tree, keys) do
    Enum.reduce(keys, tree, fn ({code, key}, tree) ->
      insert(tree, code, key)
    end)
  end

  defp do_reduce(nil, acc, _fun) do
    acc
  end

  defp do_reduce(%Node{left: nil, right: nil}=node, acc, fun) do
    fun.(node, acc)
  end

  defp do_reduce(%Node{left: nil, right: right}, acc, fun) do
    do_reduce(right, acc, fun)
  end

  defp do_reduce(%Node{left: left, right: nil}, acc, fun) do
    do_reduce(left, acc, fun)
  end

  defp do_reduce(%Node{left: left, right: right}, acc, fun) do
    do_reduce(right, do_reduce(left, acc, fun), fun)
  end
end
