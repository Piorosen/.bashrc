set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-abolish'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'taglist.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'
" Plugin 'Valloric/YouCompleteMe'



call vundle#end() 



set hlsearch " 검색어 하이라이팅
set nu " 줄번호
set autoindent " 자동 들여쓰기
set scrolloff=2
set wildmode=longest,list
set ts=4 "tag select
au Bufenter *.\(c\|cpp\|h\|py\|java\) set et
set sts=4 "st select
set sw=1 " 스크롤바 너비
set autowrite " 다른 파일로 넘어갈 때 자동 저장
set autoread " 작업 중인 파일 외부에서 변경됬을 경우 자동으로 불러옴
set cindent " C언어 자동 들여쓰기
set bs=eol,start,indent
set history=256
set laststatus=2 " 상태바 표시 항상
"set paste " 붙여넣기 계단현상 없애기
set shiftwidth=4 " 자동 들여쓰기 너비 설정
set showmatch " 일치하는 괄호 하이라이팅
set smartcase " 검색시 대소문자 구별
set smarttab
set smartindent
set softtabstop=4
set tabstop=4
set bg=dark
set ruler " 현재 커서 위치 표시
set incsearch
set title
set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F\
set term=screen-256color
:set cursorline

" 마지막으로 수정된 곳에 커서를 위치함
" 구문 강조 사용
if has("syntax")
    syntax on
endif
" 컬러 스킴 사용
" colorscheme peachpuff

let g:airline_powerline_fonts = 1
nmap <F8> :NERDTreeToggle<CR>

