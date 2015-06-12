defmodule Huffman.Tree.Node do
  alias __MODULE__, as: Node

  defstruct weight: nil, left: nil, right: nil, code: nil, key: nil

  def new(weight, key\\nil) do
    %Node{weight: weight, key: key}
  end

  def combine(nil, %Node{}=node), do: node
  def combine(%Node{}=node, nil), do: node

  def combine(%Node{weight: weight1}=node1, %Node{weight: weight2}=node2) when weight1 > weight2,
    do: combine(node2, node1)

  def combine(
    %Node{weight: weight1}=node1,
    %Node{weight: weight2}=node2)
  when weight1 <= weight2 do
    %Node{ new(weight1 + weight2) | left: node1, right: node2 }
  end

  @moduledoc """
  Sets the key for a given node

    iex> Huffman.Tree.Node.set_key(
    ...> %Node{key: "1"}, "2").key
    2

  """
  def set_key(%Node{}=node, key),
    do: %Node{node | key: key}
end
