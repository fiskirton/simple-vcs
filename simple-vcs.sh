#!/bin/bash
program_path="/home/`whoami`/.local/lib/simple-vcs"

if [[ -n "$1" ]]
then
    case "$1" in

        init)
		    $program_path/funcs/init.sh
            ;;
        add)
            $program_path/funcs/add.sh "${@:2:$#}"
            ;;
        commit)
            $program_path/funcs/commit.sh "${@:2:$#}"
            ;;
        checkout)
            $program_path/funcs/checkout.sh "${@:2:$#}"
            ;;
        push)
            $program_path/funcs/push.sh "${@:2:$#}"
            ;;
        status)
		    $program_path/funcs/status.sh
			;;
        diff)
            $program_path/funcs/diff.sh "${@:2:$#}"
            ;;
		log)
		    root=`$program_path/funcs/repo_funcs.sh root`
			cat "$root/.vcs/log.txt"
			;;
        *)
            echo "Unknown command"
            ;;
    esac
else
    echo "Command required"
fi
