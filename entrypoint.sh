#!/bin/bash

set -e
package=$1
push=$2
ssh_key=$3

git clone https://aur.archlinux.org/${package}.git
cd ${package}
makepkg -s
makepkg --printsrcinfo > .SRCINFO

if [ "$push" = "true" ]; then
  echo ${ssh_key} > ~/.ssh/private
  chmod 600 ~/.ssh/private
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/private
  git config --global user.email "aur@github-actions"
  git config --global user.name "GitHub Actions"
  git add PKGBUILD .SRCINFO
  git commit -m "Update ${package}"
  git push origin master
fi
