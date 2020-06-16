#!/bin/bash
function get_project_root {
    path="`pwd`"
    while [ "$path" != "/" ]
    do
        if [ -d "$path/.vcs" ]
        then
            echo "$path"
            return 0
        else
            path=`dirname "$path"`
        fi
    done

    echo ""
}

function get_path {
    root=`get_project_root`

    if [[ $# -lt 1 ]]
    then
        echo 'Require at least one subdir name'
        return -1
    else
        if [ -n "$root" ]
        then
            for subdir in "$@"
            do
                root="$root/$subdir"
            done 
            echo "$root"
        else
            echo "Not a repository"
            return -1
        fi
    fi
}

root=`get_project_root`

function make_subdir {
    if [[ $# -lt 1 ]]
    then
      if [[ -z "$root" ]]
      then
        mkdir ".vcs"
        else		
            echo 'Require at least one subdir name'
        fi
    else
        subpath="`get_path ".vcs" $*`"

        if [ ! -d "$subpath" ]
        then
            mkdir -p "$subpath"
        fi
    fi
}

function make_file {
    if [[ $# -lt 1 ]]
    then
        echo 'require at least one subdir name'
        return -1
    else
        path=`get_path ".vcs" ${@:1:$#-1}`

        if [ ! -d "$path" ]
        then
            make_subdir ".vcs" ${@:1:$#-1}
        fi
        
      touch "$path/${!#}"
    fi
}

function read_object {
    if [[ $# -ne 1 ]]
    then
        echo 'only sha1-name required'
        return -1
    else
        object_name=$1
        path=`get_path ".vcs" "objects" "${object_name:0:2}" "${object_name:2:${#object_name}}"`
        uncompressed=`zlib-flate -uncompress < $path`  

        obj_type=`echo -e $uncompressed | awk -F'\x20' '{print $1}'`
        obj_size=`echo -e $uncompressed | perl -lane 'print "@F[1..$#F]"' | awk -F'\x00' '{print $1}'`
        obj_data=`echo "$uncompressed" | sed -e 's#.*x00\(\)#\1#'` 

        echo "$obj_data"
    fi
}

function get_sha_path {
    sha=$1
    obj_path=`get_path ".vcs" "objects" "${sha:0:2}" "${sha:2:${#sha}}"`
    echo "$obj_path"
}

types=(blob tree commit)

function get_hash {
    if [[ $# -ne 3 ]]
    then
        echo 'take only object type flag and data/path'
        exit -1
    elif [[ ! " ${types[@]} " =~ " $1 " ]]
    then
        echo "Incorrect object type"
        exit -1
    else
      obj_type="$1"

      if [[ "$2" == "-p" ]]
      then
          file_path="$3"
          obj_data="$obj_type\x20`wc -c "$root/$file_path" | awk '{print $1}'`\x00`cat "$root/$file_path"`"
      elif [[ "$2" == "-d" ]]
      then
          raw_data="$3"
          obj_data="$obj_type\x20`echo $raw_data | wc -c`\x00`echo $raw_data`"
      else
          echo "Invalid flag"
          exit -1
      fi

      obj_sha1=`echo -n "$obj_data" | sha1sum | awk '{print $1}'`
      echo "$obj_sha1"
    fi
}

function write_object {
    if [[ $# -ne 3 ]]
    then
        echo "Type, flag, data/path required"
        return -1
    fi

    obj_sha1="`get_hash "$@"`"
    make_subdir "objects" "${obj_sha1:0:2}"
    obj_path="`get_sha_path $obj_sha1`"

    if [[ "$2" == "-p" ]]
    then
        obj_data="$1\x20`wc -c "$root/$3" | awk '{print $1}'`\x00`cat "$root/$3"`"
    elif [[ "$2" == "-d" ]]
    then
        obj_data="$1\x20`echo "$3" | wc -c`\x00`echo "$3"`"
    else
        echo "Invalid flag"
    fi

    echo -n "$obj_data" | zlib-flate -compress=4 > $obj_path
}

function hash_object {
    obj_sha1="`get_hash "$1" "$2" "$3"`"
    obj_path="`get_path ".vcs" "objects" ${obj_sha1:0:2} ${obj_sha1:2:${#obj_sha1}}`"

    if [[ -f "$obj_path" ]]
        then
        echo "$obj_sha1"
        else
        echo "no such object"
    fi
}

function cat_object {
    if [[ $# -ne 2 ]]
    then
        echo 'take only object type and data path'
    elif [[ ! " ${types[@]} " =~ " $1 " ]]
    then
        echo "Incorrect object type"
    else
        sha=$2
        dir_name=${sha:0:2}
        file_name=${sha:2:${#sha}}
        path=`get_sha_path $sha`

        if [[ -f "$path" ]]
          then
              echo `zlib-flate -uncompress < $path`
          else
              echo "no such object"
          fi
    fi
}

function ls_dir {
    dir="$root/$1"

    if [[ -d "$dir" ]]
    then
        paths=""

        for path in "$dir"/*
        do
            rel_path=`echo ${path#"$dir"} | cut -d '/' -f '2-'`
            paths="${paths}|$rel_path"
        done

        echo $paths

    else
        echo "No such dir"
    fi
}

case "$1" in
    root)
		get_project_root
		;;
    path)
		get_path "${@:2:$#}"
		;;
    subdir)
		make_subdir "${@:2:$#}"
		;;
    file)
		make_file "${@:2:$#}"
		;;
    read)
		read_object "$2"
		;;
    write)
	  write_object "${@:2:$#}"
		;;
    sha-path)
		get_sha_path "$2"
		;;
    get-hash)
		get_hash "${@:2:$#}"
		;;
    hash)
		hash_object "${@:2:$#}"
		;;
    cat)
		cat_object "$2" "$3"
		;;
    ls-dir)
		ls_dir "${@:2:$#}"
		;;
esac