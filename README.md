# Some binary tree operations using [nixla](https://github.com/dmyTRUEk/nixla)

yeah, *fun*



## Examples:
### Example 1: tokens
[btree.nix at 7244c4a](https://github.com/dmyTRUEk/btree-nixla/blob/7244c4a4bbc69bf846512e2df3248507d9ae8652/btree.nix):
```bash
$ nixla-nix btree-7244c4a.nix '(a b c)'
[ "(" "a" "b" "c" ")" ]
```


### Example 2: tree
[btree.nix at 74f7f64](https://github.com/dmyTRUEk/btree-nixla/blob/74f7f64c7b3fdd1e4782fe5f9ab5070607618fd6/btree.nix):
```bash
$ nixla-nix btree-74f7f64.nix '(a b c)'
{ data = "a"; left = "b"; right = "c"; }
```


### Example 3: tree to indented string
[btree.nix at f9c2dae](https://github.com/dmyTRUEk/btree-nixla/blob/f9c2daea9b8e1e0063ea38fad5287a1f8d427310/btree.nix):
```bash
$ nixla btree-f9c2dae.nix '(a (b 1 2) (c 3 (d (e 7 8) 6)))'
a
  b
    1
    2
  c
    3
    d
      e
        7
        8
      6
```


### Example 4: reverse tree
[btree.nix at deb6d86](https://github.com/dmyTRUEk/btree-nixla/blob/deb6d86aabf5c508b7c738ca2af3da30fe3aa70a/btree.nix):
```bash
$ nixla btree-deb6d86.nix '(a (b 1 2) (c 3 (d (e 7 8) 6)))'
a
  c
    d
      6
      e
        8
        7
    3
  b
    2
    1
```


### Example 5: traverse tree
[main.nix at b0ed48a](https://github.com/dmyTRUEk/btree-nixla/blob/b0ed48a2f122f17a5f0f1c887f3db75703e0f6e2/main.nix)
```nix
# main-b0ed48a.nix
...
tree_dfs_preorder = tree:
  if !isAttrs tree then
    [tree]
  else
    [tree.data] ++
    tree_dfs_preorder tree.left ++
    tree_dfs_preorder tree.right
;
...
```
```bash
$ nixla-nix main-b0ed48a.nix '(a (b 1 2) (c 3 (d (e 7 8) 6)))'
[ "a" "b" "1" "2" "c" "3" "d" "e" "7" "8" "6" ]
```
