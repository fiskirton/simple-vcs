program_path="/home/`whoami`/.local/lib/simple-vcs"
root="`$program_path/funcs/repo_funcs.sh root`"
index="$root/.vcs/index"
log="$root/.vcs/log.txt"

function clear_root {
    find "$root" -mindepth 1 ! -regex "^"$root"/.vcs\(/.*\)?" -delete 
}

function restore_structure {
    tree_data="`$program_path/funcs/repo_funcs.sh read $1`"
    IFS='|' read -r -a objects <<< "$tree_data" 

    local prefix="$2"
    local tree=""

    for object in "${objects[@]}"
    do
        obj_type="`echo $object | cut -d ' ' -f 1`"
        obj_sha="`echo $object | cut -d ' ' -f 2`"
        obj_path="`echo $object | cut -d ' ' -f '3-'`"

        if [[ -n "$object" ]]
        then
            rel_path="$prefix/$obj_path"
            if [[ "$obj_type" == "tree" ]]
            then
                mkdir "$root/$rel_path"
                restore_structure "$obj_sha" "$rel_path"
            elif [[ "$obj_type" == "blob" ]]
            then
                touch "$root/$rel_path"
                obj_data="`$program_path/funcs/repo_funcs.sh read "$obj_sha"`"
                echo "$obj_data" > "$root/$rel_path"
            else
                echo "unknown type"
            fi
        fi
    done
}

function checkout {
    if [[ "$#" -ne 1 ]]
    then
        echo "Takes only commit sha"
        return 0
    fi
    
    if [[ ! -f "$log" ]]
    then
        echo "There are no commits to checkout"
    elif [[ "`cat "$log" | wc -l`" -eq 1 ]]
    then
        echo "Nothing to checkout. Only one commit yet"
    elif [[ "$1" == "HEAD" ]]
    then
        head_commit_sha="`cat "$log" | tail -1`"
        commit_tree_sha="`$program_path/funcs/repo_funcs.sh read $head_commit_sha | head -n 1 | awk '{print $2}'`"
        echo "Checkout to HEAD"
        clear_root
        restore_structure "$commit_tree_sha" "."
    else
        commit_sha="$1"
        if [[ "`echo $commit_sha | wc -c`" -lt 40 ]]
        then
            echo "Only full sha(40 symb) is available"
        elif [[ -n "`cat "$log" | grep "$commit_sha"`" ]]    
        then
            commit_tree_sha="`$program_path/funcs/repo_funcs.sh read $commit_sha | head -n 1 | awk '{print $2}'`"

            echo "Checkout to $commit_sha"
            clear_root
            restore_structure "$commit_tree_sha" "."
        else
            echo "No such commit sha"
        fi
    fi
}

if [[ $# -eq 1 ]]
then
    checkout "$1"
elif [[ $# -eq 2 ]]
then
    root="$2"
    restore_structure "$1" "" 
else
    echo "Unknown parametrs"
fi
