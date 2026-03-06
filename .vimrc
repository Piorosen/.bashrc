set nocompatible
filetype plugin indent on
syntax on
let mapleader = " "

set number
set mouse=a
set ttymouse=sgr
set laststatus=2
set statusline=%f\ %h%m%r%=%{&filetype==''?'noft':&filetype}\ [%{&fileencoding==''?&encoding:&fileencoding}]\ %l:%c\ [%p%%]\ %{strftime('%H:%M')}
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set hidden

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

let g:NERDTreeWinSize = 30
let g:NERDTreeMouseMode = 2
let g:layout_initialized = 0
let g:coc_global_extensions = [
      \ 'coc-clangd',
      \ 'coc-pyright',
      \ 'coc-go',
      \ 'coc-rust-analyzer',
      \ 'coc-snippets',
      \ 'coc-json'
      \ ]

set signcolumn=yes
set updatetime=300
set shortmess+=c

" Quit all windows/tabs at once.
nnoremap <silent> <C-q> :qall!<CR>
nnoremap <silent> <leader>q :qall<CR>
nnoremap <silent> <leader>Q :qall!<CR>
nnoremap <silent> <C-w>q :wq<CR>
tnoremap <silent> <C-q> <C-\><C-n>:qall!<CR>
tnoremap <silent> <leader>q <C-\><C-n>:qall<CR>
tnoremap <silent> <leader>Q <C-\><C-n>:qall!<CR>

" IDE/LSP shortcuts (coc.nvim)
inoremap <silent><expr> <C-Space> coc#refresh()

nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)
nnoremap <silent> <leader>rn <Plug>(coc-rename)
nnoremap <silent> <leader>ca <Plug>(coc-codeaction-cursor)
xnoremap <silent> <leader>ca <Plug>(coc-codeaction-selected)
nnoremap <silent> [g <Plug>(coc-diagnostic-prev)
nnoremap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> <leader>f :call CocActionAsync('format')<CR>
nnoremap <silent> K :call <SID>ShowDocumentation()<CR>

" Simple IDE keys
nnoremap <silent> <F8> :NERDTreeToggle<CR>
nnoremap <silent> <F12> <Plug>(coc-definition)
nnoremap <silent> <S-F12> <Plug>(coc-references)
nnoremap <silent> <F2> <Plug>(coc-rename)
nnoremap <silent> <F4> :call CocActionAsync('format')<CR>

function! s:ShowDocumentation() abort
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    execute 'h ' . expand('<cword>')
  endif
endfunction

augroup CocConfig
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END

augroup IdeIndent4
  autocmd!
  autocmd FileType c,cpp,python,go,rust setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
augroup END

augroup IdeFormatOnSave
  autocmd!
  autocmd BufWritePre *.c,*.cc,*.cpp,*.h,*.hpp,*.py,*.go,*.rs silent! call CocAction('format')
augroup END

function! s:FindNerdTreeWindow() abort
  for w in range(1, winnr('$'))
    if getbufvar(winbufnr(w), '&filetype') ==# 'nerdtree'
      return w
    endif
  endfor
  return -1
endfunction

function! s:FindTerminalWindow() abort
  for w in range(1, winnr('$'))
    if getbufvar(winbufnr(w), '&buftype') ==# 'terminal'
      return w
    endif
  endfor
  return -1
endfunction

function! s:FindEditorWindow() abort
  for w in range(1, winnr('$'))
    let l:bt = getbufvar(winbufnr(w), '&buftype')
    let l:ft = getbufvar(winbufnr(w), '&filetype')
    if l:bt !=# 'terminal' && l:ft !=# 'nerdtree'
      return w
    endif
  endfor
  return -1
endfunction

function! s:FocusNerdTreeWindow() abort
  let l:w = s:FindNerdTreeWindow()
  if l:w > 0
    execute l:w . 'wincmd w'
  endif
endfunction

function! s:FocusEditorWindow() abort
  let l:w = s:FindEditorWindow()
  if l:w > 0
    execute l:w . 'wincmd w'
  endif
endfunction

function! s:FocusTerminalWindow() abort
  let l:w = s:FindTerminalWindow()
  if l:w > 0
    execute l:w . 'wincmd w'
    startinsert
  endif
endfunction

function! s:SetupFixedLayout() abort
  if g:layout_initialized
    return
  endif

  let g:layout_initialized = 1

  if s:FindNerdTreeWindow() < 0
    silent! NERDTree
  endif

  if s:FindEditorWindow() < 0
    enew
  endif

  call s:FocusEditorWindow()

  if s:FindTerminalWindow() < 0
    botright 12split
    " Use the existing split for terminal to avoid creating an extra window.
    try
      terminal ++curwin
    catch
      " Fallback if current buffer cannot be abandoned for ++curwin.
      try
        enew
        terminal ++curwin
      catch
        botright 12terminal
      endtry
    endtry
  endif

  call s:FocusEditorWindow()
endfunction

" Focus shortcuts:
" <C-j> -> NerdTree, <C-k> -> editor, <C-l> -> terminal
nnoremap <silent> <C-j> :call <SID>FocusNerdTreeWindow()<CR>
nnoremap <silent> <C-k> :call <SID>FocusEditorWindow()<CR>
nnoremap <silent> <C-l> :call <SID>FocusTerminalWindow()<CR>
tnoremap <silent> <C-j> <C-\><C-n>:call <SID>FocusNerdTreeWindow()<CR>
tnoremap <silent> <C-k> <C-\><C-n>:call <SID>FocusEditorWindow()<CR>
tnoremap <silent> <C-l> <C-\><C-n>:call <SID>FocusTerminalWindow()<CR>

augroup FixedLayout
  autocmd!
  if !exists('g:chacha_noninteractive')
    autocmd VimEnter * call s:SetupFixedLayout()
    autocmd BufWinEnter,WinEnter * if &buftype ==# 'terminal' | setlocal nonumber norelativenumber | endif
  endif
augroup END
