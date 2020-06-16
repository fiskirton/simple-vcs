program_path="/home/`whoami`/.local/lib/simple-vcs"
root="`$program_path/funcs/repo_funcs.sh root`"

if [[ $# -eq 2 ]]
then
    user="$1"
    address="$2"
    scp -rpC "$root" "$user"@"$address":"/home/$user"
fi