#!/bin/bash

# ecd
#
# Save Emacs default directory of current buffer using `save-pwd` and go to that
# directory using `ecd` in shell
function ecd() {
  eval "cd $(head -1 ~/.emacs.d/data/pwd)"
}

# proot(skip = 0)
#
# Go up until .git directory found.
# @param skip skip this number of .git and continue go up
function proot() {
  local -i skip=
  [ -n "$1" ] && skip="$1"
  local dir=`pwd`
  dir=${dir%/}

  until [ -z "$dir" ] || [ "$skip" -le 0 -a -d "$dir/.git" ]; do
    if [ -d "$dir/.git" ]; then
      let skip=skip-1
    fi
    dir=${dir%/*}
  done

  cd "$dir/"
}

# vman
#
# Open vim to read man
function vman() {
  if (($#)); then
    title='man:'
    for arg in $@; do
      if ! grep -q '^[0-9]\+\|\(-.*\)$' <<< "$arg" ; then
        title="$title $arg"
      fi
    done
    title="`sed 's/ /\\\\ /g' <<< "$title"`"

    if /usr/bin/man -w $@ >/dev/null 2>/dev/null; then
      /usr/bin/man $@ | col -b | vim -c "set ft=man nomod nonumber nolist fdm=indent fdn=2 sw=4 foldlevel=2 ro ignorecase incsearch hlsearch titlestring=$title | nmap q :q!<CR> | nmap <HOME> gg | nmap <END> G" -
    else
      echo No man page for $* >&2
    fi
  else
    /usr/bin/man
  fi
}

# take
# Create directory and cd to it
function take() {
  mkdir -p $1
  cd $1
}

# ptyless
# Fake tpy for less
ptyless () {
  zmodload zsh/zpty
  zpty ptyless ${1+"$@"}
  zpty -r ptyless > /tmp/ptyless.$$
  less -R /tmp/ptyless.$$
  rm -f /tmp/ptyless.$$
  zpty -d ptyless
}

function ls-colors()
{
  for i in {0..7}; do
    echo -e "  3$i: [7m[3${i}m       [00m"
    echo -e "1;3$i: [7m[1;3${i}m       [00m"
  done
}
function ls-256colors() {
  for i in {0..255} ; do
    printf "\x1b[38;5;${i}mcolour${i}\n"
  done
}

function ws {
  local name="$1"
  if [ -z "$name" ]; then
    name=$(basename $(git rev-parse --show-toplevel 2> /dev/null))
  fi
  if [ -z "$name" ]; then
    echo "requires a name or in git repository"
    exit 1
  fi
  mkdir -p "$HOME/workspace/$name"
  ln -nsf "$HOME/workspace/$name" workspace
}

function ep {
  local name="$1"
  if [ -z "$name" ]; then
    name=$(basename $(git rev-parse --show-toplevel 2> /dev/null))
  fi
  if [ -z "$name" ]; then
    echo "requires a name or in git repository"
    exit 1
  fi
  if ! [ -f "$HOME/Dropbox/dotfiles/eproject/$name" ]; then
    touch .eproject
    cp .eproject "$HOME/Dropbox/dotfiles/eproject/$name"
  fi
  ln -nsf "$HOME/Dropbox/dotfiles/eproject/$name" .eproject
}

function hs { [ -z "$1" ] && history || (history | grep "$@") }

function nocaps {
  setxkbmap -option ctrl:nocaps
}
