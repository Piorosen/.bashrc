#!/bin/bash


export ZPLUG_HOME=~/.zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
ln .zshrc ~/.zshrc
ln .hyper.js ~/.hyper.js
ln .p10k.zsh ~/.p10k.zsh
ln .vimrc ~/.vimrc

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

source ~/.zshrc


