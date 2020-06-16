#!/bin/bash
program_path="/home/`whoami`/.local/lib/simple-vcs"

$program_path/funcs/repo_funcs.sh subdir

root="`$program_path/funcs/repo_funcs.sh root`"
vcsdir="$root/.vcs"

$program_path/funcs/repo_funcs.sh subdir "objects"

objects="$vcsdir/objects"

$program_path/funcs/repo_funcs.sh file "HEAD"

echo -e "ref: refs/heads/master\n" > "$vcsdir/HEAD"