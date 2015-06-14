# Huffman

[Huffman](https://en.wikipedia.org/wiki/Huffman_coding) encoding and decoding.

Huffman coding is great for compressing binary data, especially with binaries
that contain a lot of repetition.

# Installation

Add the following to your mix.exs under deps:

`{:huffman, "~> 0.3"}`

# Usage

There are really just two functions to care about, `encode` and `decode`

```elixir
{encoded, keys} = Huffman.encode "Lil Wayne is the best rapper alive."
Huffman.decode encoded, keys
# returns "Lil Wayne is the best rapper alive."
```

## Internals

In case you care!

The basic formula is to calculate the frequencies of individual bytes, generate
a binary-tree structure, then walk that tree to determine each byte's encoded
value.

### Huffman.Tree

Huffman tree implementation. Can either take in a set of keys and weights to
build a corresponding tree (to calculated their encoded values) or take in a set
of codes and their corresponding codes to rebuild the tree.

Example:

Given the following codes (binary representation in comment) and keys, we can
reconstruct the huffman tree for decoding.
```elixir
codes_and_keys = %{
  {<<4::size(3)>>, "n"},  # 100
  {<<7::size(3)>>, " "},  # 111
  {<<13::size(4)>>, "i"}, # 1101
  {<<11::size(4)>>, "e"}, # 1011
  {<<10::size(4)>>, "o"}, # 1010
  {<<5::size(4)>>, "f"},  # 0101
  {<<3::size(4)>>, "a"},  # 0111
  {<<2::size(4)>>, "m"},  # 0011
  {<<1::size(4)>>, "s"},  # 0001
  {<<24::size(5)>>, "l"}, # 11000
  {<<9::size(5)>>, "x"},  # 01001
  {<<8::size(5)>>, "g"},  # 01000
  {<<0::size(5)>>, "p"},  # 00000
  {<<25::size(6)>>, "t"}  # 011001
}
Huffman.Tree.from_codes(codes_and_keys)
```
Underneath, this is what the tree will look like:
![huffmantree](https://cloud.githubusercontent.com/assets/1015847/8145854/734aaf44-11ce-11e5-9d53-353cb53df5fb.png)

