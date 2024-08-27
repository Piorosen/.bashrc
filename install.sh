#!/bin/bash


export ZPLUG_HOME=~/.zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
ln .zshrc ~/.zshrc
source ~/.zshrc


