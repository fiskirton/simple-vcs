program_path="/home/`whoami`/.local/lib/simple-vcs"
root="`$program_path/funcs/repo_funcs.sh root`"
tmp="$root/.vcs/tmp"

function get_diff {
	if [[ $# -eq 2 ]]
	then
		for sha in "$@"
		do 
			if [[ ! -f "`$program_path/funcs/repo_funcs.sh sha-path $sha`" ]]
			then
				echo "No such commit: $sha"
				return -1
			fi
		done 

		mkdir "$root/.vcs/tmp"

		$program_path/funcs/checkout.sh "$1" "$tmp/a"
		$program_path/funcs/checkout.sh "$2" "$tmp/b"

		diff --color -ruN "$tmp/a" "$tmp/b"
		rm -r "$tmp"

	elif [[ $# -eq 0 ]]
	then
		head_commit_sha="`tail -1 $root/.vcs/log.txt`" 

		mkdir "$root/.vcs/tmp"

		$program_path/funcs/checkout.sh "$head_commit_sha" "$tmp/head"	
		diff --color -ruN "$tmp/head" "$root" --exclude=".vcs"
		
		rm -r "$tmp"
	else
		echo "Only difference between two commits or between curren dir and HEAD available"
	fi	
}

get_diff "$@"