#!/bin/bash

python3 -m pip config set global.break-system-packages true
python3 -m pip install numpy pillow

export ZPLUG_HOME=~/.zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
ln .zshrc ~/.zshrc
ln .hyper.js ~/.hyper.js
ln .p10k.zsh ~/.p10k.zsh
ln .vimrc ~/.vimrc
mkdir ~/.chacharc
ln -s $(pwd)/.chacharc/ ~/.chacharc

brew tap homebrew-ffmpeg/ffmpeg
brew install homebrew-ffmpeg/ffmpeg/ffmpeg --with-libcaca
# ffmpeg -i ~/.chacharc/NyanCat.mp4 -c:v rawvideo -pix_fmt rgb24 -f caca -

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

source ~/.zshrc


