user="`whoami`"
install_path="/home/$user/.local/lib/simple-vcs"

case "$1" in
    -u)
        echo "Uninstall"
        sudo rm /usr/local/bin/simple-vcs 2>/dev/null
        rm -r "$install_path" 2>/dev/null
        ;;
    "")
        echo "Install"

        if [[ ! -d "$install_path" ]]
        then
            mkdir -p "$install_path"
        fi

        cp -rp "`pwd`"/* "$install_path" 
        sudo ln -s -f "`pwd`"/simple-vcs.sh /usr/local/bin/simple-vcs

        echo "Complete"
        ;;
    *)
        echo "Unknown flag"
        ;;
esac