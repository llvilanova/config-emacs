#!/bin/bash -e

# if [ $# -ne  ]; then
#     echo "Usage: `basename $0` <base installation path>"
#     exit 1
# fi

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

setup_files()
{
    local sourcedir targetdir sourcefile targetfile

    sourcedir=$(readlink -f $1)
    targetdir=$(readlink -f $2)
    for i in $sourcedir/*; do
        sourcefile=$(readlink -f $i)
        targetfile=$targetdir/$(basename $sourcefile)
        setup_file_rel "$sourcefile" "$targetfile"
    done
}

setup_file .config/emacs ~/.emacs.d
setup_file_rel $BASE/dot.config-emacs $HOME/.config/emacs
setup_file_rel $BASE/dot.local-share-emacs $HOME/.local/share/emacs
setup_files $BASE/bin ~/bin
