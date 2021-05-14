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

mkdir -p ~/.local/share/applications
cat >~/.local/share/applications/org-protocol.desktop <<EOF
[Desktop Entry]
Version=1.0
Name=org-protocol helper
Comment=helper to allow GNOME to open org-protocol: pseudo-urls
TryExec=/usr/bin/emacsclient
Exec=/usr/bin/emacsclient -c -F '((name . "org-protocol-capture"))' %u
NoDisplay=true
Icon=emacs24
Terminal=false
Type=Application
EOF

touch ~/.config/mimeapps.list
grep -v "^x-scheme-handler/org-protocol=.*" ~/.config/mimeapps.list >~/.config/mimeapps.list.new
cat >>~/.config/mimeapps.list.new <<EOF
[Added Associations]
x-scheme-handler/org-protocol=org-protocol.desktop;
EOF
mv ~/.config/mimeapps.list.new ~/.config/mimeapps.list

echo "Setting up Emacs... done"
