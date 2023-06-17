#!/bin/bash

set -e
package=$1
push=$2
ssh_private_key=$3

pacman -Sy base-devel git openssh --noconfirm

useradd -m -s /bin/bash builder
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

chmod 777 -R $(pwd)

if [ "$push" = "true" ]; then
  mkdir -p ~/.ssh
  echo ${ssh_private_key} > ~/.ssh/private_key
  chmod 600 ~/.ssh/private_key
  ssh-keyscan aur.archlinux.org >> ~/.ssh/known_hosts
  chmod 644 ~/.ssh/known_hosts
  git config --global user.email "aur@github-actions"
  git config --global user.name "GitHub Actions"
fi

su builder -c "git clone https://aur.archlinux.org/${package}.git"
su builder -c "cd ${package} && makepkg -s --noconfirm && rm .SRCINFO && makepkg --printsrcinfo > .SRCINFO"

if [ "$push" = "true" ]; then
  git add PKGBUILD .SRCINFO
  git commit -m "Update ${package}"
  git push origin master
fi
