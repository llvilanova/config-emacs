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

setup_file $HOME/.config/emacs $HOME/.emacs.d
mkdir -p $HOME/.config
setup_file_rel $BASE/dot.config-emacs $HOME/.config/emacs
mkdir -p $HOME/.local/share
setup_file_rel $BASE/dot.local-share-emacs $HOME/.local/share/emacs

ctrl_c() {
    exit 1
}
trap ctrl_c INT

# Run until successfully finishes or same error message repeats
set -o pipefail
prevline=""
TMPFILE=`mktemp`
while true; do
    set +e
    /usr/bin/emacs --batch --eval '(load-file "~/.config/emacs/init.el")' |& tee $TMPFILE
    RES=$?
    set -e

    line=`tail -1 $TMPFILE`
    if [ "$RES" == 0 -o "$prevline" == "$line" ]; then
        break
    fi
    prevline="$line"
done

rm -f $TMPFILE

if [ $RES -eq 0 ]; then
    echo
    echo
    echo
    echo "You should add '$BASE/bin' to your PATH"
    echo
    echo
fi

exit $RES
