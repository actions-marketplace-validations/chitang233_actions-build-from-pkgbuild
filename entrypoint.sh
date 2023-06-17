#!/bin/bash

set -e
package=$1
push=$2
ssh_key=$3

pacman -Sy base-devel git --noconfirm

useradd -m -s /bin/bash -G sudo builder
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chmod -R 777 ${package}

su builder -c "git clone https://aur.archlinux.org/${package}.git"
su build -c "cd ${package} && makepkg -s && makepkg --printsrcinfo > .SRCINFO"

if [ "$push" = "true" ]; then
  echo ${ssh_key} > ~/.ssh/private
  chmod 600 ~/.ssh/private
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/private
  ssh-keyscan -t rsa aur.archlinux.org >> ~/.ssh/known_hosts
  chmod 644 ~/.ssh/known_hosts
  git config --global user.email "aur@github-actions"
  git config --global user.name "GitHub Actions"
  git add PKGBUILD .SRCINFO
  git commit -m "Update ${package}"
  git push origin master
fi
