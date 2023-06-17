#!/bin/bash

set -e
package=$1
push=$2
ssh_private_key=$3

pacman -Sy base-devel git --noconfirm

useradd -s /bin/bash builder
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

chmod 777 -R $(pwd)

if [ "$push" = "true" ]; then
  echo ${ssh_private_key} > ~/.ssh/id_ed25519
  chmod 600 ~/.ssh/id_ed25519
  ssh-keyscan -t rsa aur.archlinux.org >> ~/.ssh/known_hosts
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
