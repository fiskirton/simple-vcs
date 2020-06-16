program_path="/home/`whoami`/.local/lib/simple-vcs"
root="`$program_path/funcs/repo_funcs.sh root`"
index="$root/.vcs/index"

function get_text_after {
	echo "$1" | cut -d "$2" -f '2-'
}

function make_tree {
	IFS='|' read -r -a paths <<< "$1" 

	local prefix="$2"
	local tree=""
	local skip="|"

	for path in "${paths[@]}"
	do
		if [[ -n "`echo "$path" | grep "/"`" ]]
		then
			new_prefix="`echo "$path" | cut -d '/' -f 1`"
			rel_path="$prefix$new_prefix"
			if [[ -z "`echo "$skip" | grep "|$new_prefix|"`"  ]]
			then
				skip="$skip$new_prefix|" 
				postfix=""
				while read line
				do
					if [[ -n "`echo "$line" | grep " $rel_path/"`" ]]
					then
						postfix="$postfix`echo "$line" | sed -n -e "s#^.* $rel_path/##p"`|"
					fi
				done < "$index"

				tree_data="`make_tree "$postfix" "$rel_path/"`"
				$program_path/funcs/repo_funcs.sh write "tree" "-d" "$tree_data"
				tree_data_sha="`$program_path/funcs/repo_funcs.sh hash tree -d "$tree_data"`"
				tree="$tree"tree" "$tree_data_sha" "$new_prefix"|"

			fi
		else
			obj_sha="`cat $index | grep " $prefix$path$" | cut -d ' ' -f 1`"
			tree="$tree"blob" $obj_sha "$path"|"
		fi	
	done

	echo "$tree"
}

function commit {
	if [[ ! -f "$index" ]]
	then
		echo "Add some file to index at first!"
	elif [[ "$#" -ne 1 ]]
	then
		echo "Should receive commit message"
	elif [[ -z "$1" ]]
	then
		echo "Commit message can't be empty string"
	elif [[ -z "`diff "$index.old" "$index"`"  ]]
	then
		echo "No changes to commit. Add files to index at first"
	else
		index_paths=""

		while read line
		do
			index_paths="$index_paths`get_text_after "$line" " "`|"
		done < "$index"

		commit_tree="`make_tree "$index_paths" ""`"
		$program_path/funcs/repo_funcs.sh write "tree" "-d" "$commit_tree"
		commit_tree_sha="`$program_path/funcs/repo_funcs.sh hash "tree" "-d" "$commit_tree"`"

		if [[ ! -f "$root/.vcs/log.txt" ]]
		then
			touch "$root/.vcs/log.txt"
			commit_data="tree $commit_tree_sha
	date `date`
	commiter `whoami`
	message $1"
		else
			commit_data="tree $commit_tree_sha
	parent `tail -1 "$root/.vcs/log.txt"`
	date `date`
	commiter `whoami`
	message $1"
		fi
		
		$program_path/funcs/repo_funcs.sh write "commit" "-d" "$commit_data"
		commit_sha="`$program_path/funcs/repo_funcs.sh hash commit -d "$commit_data"`"		
		echo "$commit_sha" >> "$root/.vcs/log.txt"
		cat "$index" > "$index.old"
	fi
}

commit "$1"

