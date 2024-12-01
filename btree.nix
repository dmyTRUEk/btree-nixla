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

in
	input:
	input
		|> string_to_list
