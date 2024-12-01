let
	inherit (builtins)
		concatMap
		elem
		elemAt
		filter
		foldl'
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
						acc
						# unreachable ""
				else #if acc.br_level == 0 then
					if acc.is_writing_to_left then
						acc // { left_tokens = acc.left_tokens ++ [el]; }
					else
						acc // { right_tokens = acc.right_tokens ++ [el]; }
					# throw "should be unreachable"
			)
			{
				br_level = 0;
				data = null;
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

in
	input:
	input
		|> input_to_tokens
		|> tokens_to_tree
