program_path="/home/`whoami`/.local/lib/simple-vcs"
root="`$program_path/funcs/repo_funcs.sh root`"
index="$root/.vcs/index"

function print_array {
    if [[ -n "$1" ]]
    then
        echo "----$2----"

        IFS='|' read -r -a objects <<< "$1" 
        for obj in "${objects[@]}"
        do
            echo "$obj"
        done
    fi
}

function status {
    staged=""
    modified=""
    deleted=""
    untracked=""

    while IFS= read -r -d $'' path    
    do
        rel_path="`echo -e "${path#"$root"}" | cut -d '/' -f '2-'`"
        obj_sha="`$program_path/funcs/repo_funcs.sh get-hash blob -p "$rel_path"`" 
        
        if [[ ! -f "$index" || -z "`grep " $rel_path$" "$index"`" ]]
        then
            untracked="$untracked$root/$rel_path|"
        elif [[ -z "`grep "$obj_sha $rel_path$" "$index"`" ]]
        then
            modified="$modified$root/$rel_path|"
        elif [[ -n "`grep "$obj_sha $rel_path$" "$index"`" && -z "`grep "$obj_sha $rel_path$" "$index.old"`"  ]]  
        then
            staged="$staged$root/$rel_path|"
        fi
    done < <(find "$root" -type f -not -path "*/\.vcs/*" -print0)
    
    if [[ -f "$index.old" ]]
    then
        while read line
        do
            rel_path="`echo $line | cut -d ' ' -f '2-'`"
            if [[ -z "`grep " $rel_path$" "$index"`" ]]
            then
                deleted="$deleted$root/$rel_path"
            fi
        done < "$index.old"
    fi

    if [[ -z "$staged" && -z "$modified" && -z "$untracked" && -z "$deleted" ]]
    then
        echo "Latest changes"
    else
        print_array "$staged" "staged"
        print_array "$modified" "modified"
        print_array "$deleted" "deleted"
        print_array "$untracked" "untracked"
    fi
}

if [[ -z "$root" ]]
then
    echo "Not a repository"
    exit -1
fi

status
