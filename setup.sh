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
PATH="$BASE/bin":\$PATH

EDITOR="$BASE/bin/default-editor"
VISUAL="\$EDITOR -nw"
export EDITOR ALTERNATE_EDITOR VISUAL

alias e="\$EDITOR"
alias et=emacs-terminal
alias er=emacs-frame-reuse
alias en=emacs-frame-new
alias E="SUDO_EDITOR=\"\$EDITOR -t -a emacs\" sudoedit"

ediff () { emacs-open --eval "(ediff \"\$1\" \"\$2\")"; }
gdbtool () { emacs-open --eval "(gdb \"gdb -i=mi \$*\")";}
EOF

echo " done"

echo "You should add the following to your ~/.bashrc:"
echo "  source $BASE/bashrc"
