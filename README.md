# simple-vcs

## Get started

> install

```
$ git clone https://github.com/fiskirton/simple-vcs.git
$ cd simple-vcs
# ./install.sh
```
> uninstall
```
$ cd simple-vcs
$ ./install.sh -u
```

## Usage

```
$ simple-vcs init
$ simple-vcs add FILE...
$ simple-vcs commit COMMIT-MESSAGE
$ simple-vcs checkout [commit-sha|HEAD]  
$ simple-vcs status
$ simple-vcs diff [commit1-sha] [commit2-sha]
$ simple-vcs push USER ADDRESS
```

> Commands
- `init` - init repository
- `add` - add files to the index
- `commit` - commit changes from the index
- `checkout` - switch to another commit
- `status` - display repository changes
- `diff` - show difference between commits
- `push` - push to remote host
