My Emacs configuration, in case there's some bits that might be useful to you.

Install
-------

Clone and run setup.sh to point all files and configuration directories to your
clone of the repository (can be run as many times as you want, in case you move
your clone around):

  git clone ... ~/emacs-config
  ~/emacs-config/setup.sh

This generates a small bash script that you should include from your main
bash configuration file (setup.sh prints the path after generating it). It sets
Emacs as your default editor, and makes some additional commands and aliases
available to start Emacs (see the generated file for a complete list).