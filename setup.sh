#!/bin/bash -e

echo -n "Setting up Emacs's directories..."

BASE=$(dirname `readlink -f $0`)

# return path to $2 relative to directory $1
to_relative()
{
    local source target common_part back

    source=$(readlink -f $1)
    target=$(readlink -f $2)
    common_part=$source
    back=
    while [ "${target#$common_part}" = "${target}" ]; do
        common_part=$(dirname "$common_part")
        back="../${back}"
    done

    echo ${back}${target#$common_part/}
}

setup_file()
{
    local sourcefile targetfile

    sourcefile=$1
    targetfile=$2

    # if exists, just let the user have it
    if [ -e "$2" ]; then
        return
    fi

    mkdir -p $(dirname "$2")
    ln -s "$1" "$2"
}

setup_file_rel()
{
    local sourcerel

    sourcerel=$(to_relative "`dirname $2`" "$1")
    setup_file $sourcerel $2
}

setup_file $HOME/.config/emacs $HOME/.emacs.d
mkdir -p $HOME/.config
setup_file_rel $BASE/dot.config-emacs $HOME/.config/emacs
mkdir -p $HOME/.local/share
setup_file_rel $BASE/dot.local-share-emacs $HOME/.local/share/emacs

cat >$BASE/bashrc <<EOF
# use Emacs as default editor
EDITOR="$BASE/bin/default-editor"
VISUAL="\$EDITOR -nw"
export EDITOR ALTERNATE_EDITOR VISUAL

# add new commands to your search path
PATH="$BASE/bin":\$PATH

# open an emacs frame
alias e="\$EDITOR"
# open an emacs frame in console-mode
alias et="\$VISUAL"
# open an emacs frame as root
alias E="SUDO_EDITOR=\"\$EDITOR -t -a emacs\" sudoedit"

# open emacs frame with ediff on two file
ediff () { emacs-open --eval "(ediff \"\$1\" \"\$2\")"; }
# open emacs frame with a new gdb session
gdbtool () { emacs-open --eval "(gdb \"gdb -i=mi \$*\")";}
EOF

sudo apt install clang-tools bear nodejs
mkdir -p $HOME/.local/share/emacs/snippets
mkdir -p $HOME/.local/share/emacs/yasnippet-snippets

echo " done"

echo "You should add the following to your ~/.bashrc:"
echo "  source $BASE/bashrc"
