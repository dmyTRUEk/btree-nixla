let
	inherit (builtins)
		concatMap
		elem
		elemAt
		filter
		foldl'
		isAttrs
		isList
		length
		split
	;

	unreachable = msg: throw "unreachable reached: " + msg;

	split_ = sep_regex: str: filter (el: el != []) (split sep_regex str);

	# tree example:
	# tree = {
	# 	data = "a";
	# 	left = "b";
	# 	# right = "c";
	# 	right = { data = "c"; left = "1"; right = "2"; };
	# };

	# FIXME
	# reverse_list = list:
	# 	foldl'
	# 		(acc: el: { n=acc.n+1; list=acc.list ++ [elemAt list (length list - acc.n - 1)]; })
	# 		{ n=0; list=[]; }
	# 		list
	# 	;

	string_to_list = string: filter (el: el != "") (split_ "" string);

	# src: https://github.com/hsjobeki/nixpkgs/blob/migrate-doc-comments/lib/lists.nix#L431:C3
	flatten_list = x: if isList x then concatMap (y: flatten_list y) x else [x];

	input_to_tokens = input:
		filter
			(el: el != "" && el != " ")
			(flatten_list (split "([ \(\)])" input))
	;

	tokens_to_tree = tokens:
		let interim_tree = foldl'
			(acc: el:
				if el == "(" then
					acc // rec {
						br_level = acc.br_level + 1;
						left_tokens = if acc.is_writing_to_left && br_level != 1 then acc.left_tokens ++ [el] else acc.left_tokens;
						right_tokens = if !acc.is_writing_to_left && br_level != 1 then acc.right_tokens ++ [el] else acc.right_tokens;
					}
				else if el == ")" then
					acc // rec {
						br_level = acc.br_level - 1;
						is_writing_to_left = if br_level == 1 then false else acc.is_writing_to_left;
						left_tokens = if acc.is_writing_to_left && acc.br_level != 1 then acc.left_tokens ++ [el] else acc.left_tokens;
						right_tokens = if !acc.is_writing_to_left && acc.br_level != 1 then acc.right_tokens ++ [el] else acc.right_tokens;
					}
				else if acc.br_level == 1 then
					if acc.data == null then
						acc // { data = el; }
					else if acc.left_tokens == [] then
						acc // { left_tokens = [el]; is_writing_to_left = false; }
					else if acc.right_tokens == [] then
						acc // { right_tokens = [el]; }
					else
						# acc
						unreachable "el = ${el}, acc = ${acc}"
				else #if acc.br_level == 0 then
					if acc.is_writing_to_left then
						acc // { left_tokens = acc.left_tokens ++ [el]; }
					else
						acc // { right_tokens = acc.right_tokens ++ [el]; }
					# throw "should be unreachable"
			)
			{
				br_level = 0;
				data = null; # TODO(refactor): extract default value
				is_writing_to_left = true;
				left_tokens = [];
				right_tokens = [];
			}
			tokens;
		in
		# interim_tree
		{
			data = interim_tree.data;
			left = if length interim_tree.left_tokens == 0
				then null
				else if (elem "(" interim_tree.left_tokens)
					then (tokens_to_tree interim_tree.left_tokens)
					# else interim_tree.left_tokens;
					else (elemAt interim_tree.left_tokens 0);
			right = if length interim_tree.right_tokens == 0
				then null
				else if (elem "(" interim_tree.right_tokens)
					then (tokens_to_tree interim_tree.right_tokens)
					# else interim_tree.right_tokens;
					else (elemAt interim_tree.right_tokens 0);
		}
	;

	repeat_string = string: n:
		if n == 0 then "" else (string + repeat_string string (n - 1))
	;

	tree_to_string_indented_ = tree: indent:
		(repeat_string "  " indent) + (
			if isAttrs tree then
				tree.data + "\n"
				+ (tree_to_string_indented_ tree.left  (indent+1)) + "\n"
				+ (tree_to_string_indented_ tree.right (indent+1))
			else
				tree
		)
	;
	tree_to_string_indented = tree:
		tree_to_string_indented_ tree 0;

	tree_reverse = tree:
		if isAttrs tree then
			{
				data  = tree.data;
				left  = tree_reverse tree.right;
				right = tree_reverse tree.left;
			}
		else
			tree
	;

	tree_dfs_preorder = tree:
		if !isAttrs tree then
			[tree]
		else
			[tree.data] ++
			tree_dfs_preorder tree.left ++
			tree_dfs_preorder tree.right
	;

	tree_dfs_inorder = tree:
		if !isAttrs tree then
			[tree]
		else
			tree_dfs_inorder tree.left ++
			[tree.data] ++
			tree_dfs_inorder tree.right
	;

	tree_dfs_postorder = tree:
		if !isAttrs tree then
			[tree]
		else
			tree_dfs_postorder tree.left ++
			tree_dfs_postorder tree.right ++
			[tree.data]
	;

in
	input:
	input
		|> input_to_tokens
		|> tokens_to_tree
		# |> tree_to_string_indented
		# |> tree_reverse
		|> tree_dfs_preorder
		# |> tree_dfs_inorder
		# |> tree_dfs_postorder
