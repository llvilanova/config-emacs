#!/bin/bash -e

BASE=$(dirname `readlink -f $0`)

echo "Setting up Emacs..."

mkdir -p $HOME/.config
rm -Rf $HOME/.config/emacs $HOME/.emacs.d
ln -s $BASE/dot.config-emacs $HOME/.config/emacs
ln -s $HOME/.config/emacs $HOME/.emacs.d

mkdir -p $HOME/.local/share
rm -Rf $HOME/.local/share/emacs
ln -s $BASE/dot.local-share-emacs $HOME/.local/share/emacs

cat >$BASE/bashrc <<EOF
#!/bin/bash

# use Emacs as default editor
EDITOR="default-editor"
VISUAL="\$EDITOR -nw"
export EDITOR ALTERNATE_EDITOR VISUAL

# add new commands to search path
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
touch ~/.bashrc
grep -v "^source .*/config-emacs/bashrc$" ~/.bashrc > ~/.bashrc.new
echo "source $BASE/bashrc" >> ~/.bashrc.new
mv ~/.bashrc.new ~/.bashrc

# sudo apt install -y clang-tools bear nodejs
sudo apt install -y bear nodejs
mkdir -p $HOME/.local/share/emacs/snippets
mkdir -p $HOME/.local/share/emacs/yasnippet-snippets


echo "Setting up Emacs... done"
