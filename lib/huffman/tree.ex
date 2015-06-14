defmodule Huffman.Tree do
  alias __MODULE__, as: Tree
  alias Huffman.Tree.Node
  import Huffman.Helpers

  defstruct root: nil

  def new([]) do
    %Tree{}
  end

  @doc """
    Creates a new huffman tree with the included frequencies
    `Huffman.Tree.new([{"a", 1}, {"b", 1}, {"c", 4}, {"x", 9}])`
  """
  def new(frequencies) do
    leaf_nodes(frequencies)
    |> build(new([]))
  end

    defp leaf_nodes(frequencies),
      do: leaf_nodes(frequencies, [])

    defp leaf_nodes([], acc),
      do: Enum.reverse(acc)

    defp leaf_nodes([{code, weight}], acc) do
      Enum.reverse([Node.new(weight, code) | acc])
    end

    defp leaf_nodes([{code, weight} | tail], acc) do
      new_acc = [Node.new(weight, code) | acc]
      leaf_nodes(tail, new_acc)
    end

  def build([], %Tree{}=tree) do
    tree
  end

  def build([%Node{}=node], %Tree{root: root}=tree) do
    if root do
      %Tree{tree| root: Node.combine(node, root)}
    else
      %Tree{tree| root: node}
    end
    |> recode
  end

  def build([%Node{}=node1, %Node{}=node2|tail], %Tree{}=tree) do
    combined_node = Node.combine(node1, node2)
    sorted_nodes([combined_node|tail])
    |> build(tree)
  end

    defp sorted_nodes(nodes) do
      weight_mapper = fn (%Node{weight: weight}) -> weight end
      Enum.sort_by(nodes, weight_mapper)
    end

  @doc """
  Takes a list of codes and their corresponding bytes, rebuilding the tree (
  without weights)
  """
  def from_codes(codes) do
    sorted_codes = Enum.reverse Enum.sort_by(codes, &elem(&1, 0), &code_sorter/2)
    do_from_codes(%Tree{}, sorted_codes)
  end

    defp do_from_codes(tree, keys) do
      Enum.reduce(keys, tree, fn ({code, key}, tree) ->
        insert(tree, code, key)
      end)
    end

    defp code_sorter(code1, code2) when bit_size(code1) > bit_size(code2), do: false
    defp code_sorter(code1, code2) when bit_size(code1) < bit_size(code2), do: true
    defp code_sorter(<<0::1, _rest1::bits>>, <<1::1, _rest2::bits>>), do: true
    defp code_sorter(<<1::1, _rest1::bits>>, <<0::1, _rest2::bits>>), do: false
    defp code_sorter(<<_bit1::1, code1::bits>>, <<_bit2::1, code2::bits>>) do
      code_sorter(code1, code2)
    end


  @doc """
  Returns a the tree as a map. By default, maps codes (the encoded bits) to keys
  (the byte it decodes into.) Optional second argument can give the inverse (
  keys => codes)
  """
  def to_map(tree, by\\:codes)
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

  @doc """
  Gets a key based on its code. Returns the key, and the unused part
  of the supplied code.

      iex> Huffman.Tree.new([{"a", 1}, {"b", 1}, {"c", 4}, {"x", 9}])
      ...> |> Huffman.Tree.get_key(<<0::1, 0::1, 1::1>>)
      {"b", <<>>}

  It returns the unused portion of the code as well since in decoding
  you aren't always sure what the next code is going to be until you find the
  key that matches. This allows you to simply pass in the decoded part and it
  will return the first decoded key.
  """
  def get_key(%Tree{root: root}, key_bits) when is_bitstring(key_bits) do
    do_get_key(key_bits, root)
  end

  defp do_get_key(rest, %Node{left: nil, right: nil, key: key}) do
    {key, rest}
  end

  defp do_get_key(<<0::1, rest::bits>>, %Node{left: left}) when not is_nil(left) do
    do_get_key(rest, left)
  end

  defp do_get_key(<<1::1, rest::bits>>, %Node{right: right}) when not is_nil(right) do
    do_get_key(rest, right)
  end

  @doc """
  The string representation of a Huffman.Tree. Basically a map from codes to
  their decoded value.
  """
  def to_string(%Tree{}=tree) do
    internals = reduce(tree, [], fn (node, acc) ->
      code_bits = inspect_bits(node.code)
      [ "#{code_bits} => #{node.key}" | acc]
    end) |> Enum.join(", ")
    "#Huffman.Tree< #{internals} >"
  end

  @doc """
    Calls the supplied function for each leaf node.
  """
  def reduce(%Tree{root: root}, acc, fun) do
    do_reduce(root, acc, fun)
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
      left: recode(left, <<code::bits, 0::size(1)>>),
      right: recode(right, <<code::bits, 1::size(1)>>)
    }
  end

  def insert(%Tree{root: root}, code, key) when is_bitstring(code) do
    root = root || %Node{}
    %Tree{root: do_insert(code, code, key, root)}
  end

    defp do_insert(<<0::1>>, code, key, %Node{}=node) do
      %Node{node | left: %Node{code: code, key: key}}
    end

    defp do_insert(<<1::1>>, code, key , %Node{}=node) do
      %Node{node | right: %Node{code: code, key: key}}
    end

    defp do_insert(<<0::1, rest::bits>>, code, key, %Node{left: left}=node) do
      new_left = do_insert(rest, code, key, left || %Node{})
      %Node{ node | left: new_left}
    end

    defp do_insert(<<1::1, rest::bits>>, code, key, %Node{right: right}=node) do
      new_right = do_insert(rest, code, key, right || %Node{})
      %Node{ node | right: new_right}
    end
end

defimpl Inspect, for: Huffman.Tree do
  def inspect(tree, _opts) do
    Huffman.Tree.to_string(tree)
  end
end
