program_path="/home/`whoami`/.local/lib/simple-vcs"
root=`$program_path/funcs/repo_funcs.sh root`

function add_file {
    file_path="$1"
    if [[ -f "$root/$file_path" ]]
    then
        entry_sha="`$program_path/funcs/repo_funcs.sh get-hash "blob" "-p" "$file_path"`"

        if [[ -n `cat "$index_path" | grep " $file_path$"` ]]
        then
            if [[ -z `cat "$index_path" | grep "^$entry_sha $file_path$"` ]]
            then
                $program_path/funcs/repo_funcs.sh write "blob" "-p" "$file_path"
                sed -i "s#^.* $file_path#$entry_sha $file_path#" "$index_path"
                echo ""$file_path" updated in the index"
            fi	
        else
            $program_path/funcs/repo_funcs.sh write "blob" "-p" "$file_path"	
            echo "$entry_sha $file_path" >> "$index_path"	
            echo ""$file_path" added to the index"
        fi
    else
        echo "No such path in repository: $file_path"
    fi
}

function add_files {
    local newarray
    newarray=("$@")
    echo "Passed files:"

    for file in "${newarray[@]}" ; do
        add_file "$file"
    done
}

function add_all {
    while IFS= read -r -d $'\0' path    
	do
		rel_path="`echo -e "${path#"$root"}" | cut -d '/' -f '2-'`"
        add_file "$rel_path"
    done < <(find "$root" -type f -not -path '*/\.vcs/*' -print0)
}

function update_index {
    index=""

    while read line
    do 
        file_path="$root/`echo "$line" | cut -d ' ' -f '2-'`"
        if [[ -f "$file_path"  ]]
        then
            index="$index$line\n"
        fi
    done < "$index_path"

    echo -e "$index" > "$index_path"
    sed -i '$ d' "$index_path"
}

index_path="`$program_path/funcs/repo_funcs.sh path ".vcs" "index"`"
stage_path="`$program_path/funcs/repo_funcs.sh path ".vcs" "stage"`"

if [[ ! -f "$index_path" ]]
then
    touch "$index_path"
	touch "$index_path.old"
fi

if [[ "$#" -lt 1 ]]
then 
   echo "Takes at least 1 file"
else
    update_index
    if [[ "$1" == "." ]]
    then
        add_all
    elif [[ "$#" -eq 1 ]]
    then
        add_file "$1"
    else
        add_files "$@"
    fi
fi