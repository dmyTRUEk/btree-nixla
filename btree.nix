let
	inherit (builtins)
		concatMap
		filter
		isList
		split
	;

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
in
	input:
	input
		|> input_to_tokens
