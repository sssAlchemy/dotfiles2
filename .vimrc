set t_Co=256
syntax on
colorscheme mrkn256

" general settings{{{
filetype plugin indent on
set backspace=indent,eol,start 
set errorformat=%m\ in\ %f\ on\ line\ %l
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=white
match ZenkakuSpace /　/
set nocompatible
set directory=/tmp
set number
set scrolloff=5
set textwidth=0
set nobackup
set expandtab
set tabstop=4
set sw=4
set ignorecase
set smartcase
set wrapscan
set incsearch
set list
set listchars=tab:\ \ ,extends:<,trail:\ 
set showmode
set hlsearch
set laststatus=2
set wildmode=list:longest,full
set hidden
set autoread
set title
au BufNewFile,BufRead * set iminsert=0
set matchpairs+=<:>
set splitright
set splitbelow
set pumheight=20
set ambiwidth=double
set autoindent
set smartindent
"}}}
" mouse
if has("mouse")
    set mouse=a
endif
"}}}
" カレントウィンドウにのみ罫線を引く
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorcolumn nocursorline
  autocmd WinEnter,BufRead * set cursorcolumn cursorline
augroup END

highlight CursorLine ctermbg=black guibg=black
highlight CursorColumn ctermbg=black guibg=black

"prompt{{{
set ruf=%45(%12f%=\ %m%{'['.(&fenc!=''?&fenc:&enc).']'}\ %l-%v\ %p%%\ [%02B]%)
set statusline=[%{winnr('$')>1?winnr().'/'.winnr('$'):''}]%f:%{substitute(getcwd(),'.*/','','')}\ %m%=%{(&fenc!=''?&fenc:&enc).':'.strpart(&ff,0,1)}\ %l-%v\ %p%%\ %02B
"}}}

"mapping{{{
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
noremap X ^x
nmap n nzz
nmap N Nzz
"silent! nmap <unique> <C-q> <Plug>(quickrun)

"insnertモードで移動
inoremap <C-b> <Left>
"inoremap <C-n> <Down>
"inoremap <C-k> <Up>
inoremap <C-f> <Right>
inoremap <C-a> <Home>
inoremap <C-d> <Del>
" カーソル前の文字削除
inoremap <silent> <C-h> <C-g>u<C-h>
" カーソル後の文字削除
inoremap <silent> <C-d> <Del>
" カーソルから行末まで削除
inoremap <silent> <C-k> <Esc>lc$
nnoremap <Esc><Esc> :<C-u>nohlsearch<Return>

"Ctrl+Tabでタブ切替
nnoremap <C-Tab>   gt
nnoremap <C-S-Tab> gT

"id:parasporospa
command! Utf8 e ++enc=utf-8
command! Euc e ++enc=euc-jp
command! Sjis e ++enc=cp932
command! Jis e ++enc=iso-2022-jp
command! WUtf8 w ++enc=utf-8 | e
command! WEuc w ++enc=euc-jp | e
command! WSjis w ++enc=cp932 | e
command! WJis w ++enc=iso-2022-jp | e
"}}}

" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

"encoding{{{
" 文字コード関連
" from ずんWiki http://www.kawaz.jp/pukiwiki/?vim#content_1_7
" 文字コードの自動認識
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
    " iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
" 改行コードの自動認識
set fileformats=unix,dos,mac
"}}}

" 前回終了したカーソル行に移動
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

""" neocomplcache
let g:neocomplcache_enable_at_startup = 1
function InsertTabWrapper()
    if pumvisible()
        return "\<c-n>"
    endif
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k\|<\|/'
        return "\<tab>"
    elseif exists('&omnifunc') && &omnifunc == ''
        return "\<c-n>"
    else
        return "\<c-x>\<c-o>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
""" autocomplete
""autocmd FileType *
""\   if &l:omnifunc == ''
""\ |   setlocal omnifunc=syntaxcomplete#Complete
""\ | endif
""
"""<TAB>で補完
""function! InsertTabWrapper()
""	let col = col('.') - 1
""	if !col || getline('.')[col - 1] !~ '\k'
""		return "\<TAB>"
""	else
""		if pumvisible()
""			return "\<C-N>"
""		else
""			return "\<C-N>\<C-P>"
""		end
""	endif
""endfunction
""" Remap the tab key to select action with InsertTabWrapper
""inoremap <tab> <c-r>=InsertTabWrapper()<cr>
""inoremap <expr> <CR> pumvisible() ? "\<C-Y>\<CR>" : "\<CR>"
""" }}} Autocompletion using the TAB key

"括弧を補完
"{{{
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>
vnoremap { "zdi^V{<C-R>z}<ESC>
vnoremap [ "zdi^V[<C-R>z]<ESC>
vnoremap ( "zdi^V(<C-R>z)<ESC>
vnoremap " "zdi^V"<C-R>z^V"<ESC>
vnoremap ' "zdi'<C-R>z'<ESC>
"}}}

" svn diff
nmap \d :call SVNDiff()<CR>
function! SVNDiff()
  echo system('svn diff --diff-cmd diff -x --normal ' . expand("%:p"))
endfunction

" vim-pathogen
call pathogen#runtime_append_all_bundles()

" NERD_tree.vim
nmap <silent> <C-D> :NERDTreeToggle<CR>
" 現在表示しているファイルのディレクトリを表示
nnoremap <silent> ,ntd  :NERDTree <C-R>=expand("%:p:h")<CR><CR>
" 隠しファイルの表示ON
let NERDTreeShowHidden = 1

nnoremap <S-a> :args
nnoremap <S-n> :n<CR>
nnoremap <S-p> :prev<CR>

nnoremap <C-h> :vsp<CR> :exe("tjump ".expand('<cword>'))<CR>
nnoremap <C-k> :split<CR> :exe("tjump ".expand('<cword>'))<CR>

nnoremap sh <C-w>h
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l

""" vim-unite
" 縦分割でスタート
let g:unite_enable_split_vertically = 1
" バッファ一覧
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
" 常用セット
nnoremap <silent> ,uu :<C-u>Unite buffer file_mru<CR>
" 全部乗せ
nnoremap <silent> ,ua :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>
" ウィンドウを分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
" ウィンドウを縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
" ESCキーを2回押すと終了する
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> q
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>q
" 選んだディレクトリからrecする
let s:unite_action_rec = {}
function! s:unite_action_rec.func(candidate)
  call unite#start([['file_rec', a:candidate.action__path]])
endfunction
""call unite#custom_action('directory', 'rec', s:unite_action_rec)
unlet! s:unite_action_rec

" 行末スペースハイライト
highlight WhitespaceEOL ctermbg=gray guibg=gray
match WhitespaceEOL /\s\+$/
autocmd WinEnter * match WhitespaceEOL /\s\+$/

" ウィンドウ移動を行うと自動的に横幅修正
"nnoremap <C-w>h <C-w>h:call <SID>good_width()<Cr>
"nnoremap <C-w>l <C-w>l:call <SID>good_width()<Cr>
"nnoremap <C-w>H <C-w>H:call <SID>good_width()<Cr>
"nnoremap <C-w>L <C-w>L:call <SID>good_width()<Cr>
"function! s:good_width()
"  if winwidth(0) < 84
"    vertical resize 84
"  endif
"endfunction

" yunkしたときclipboardにこぴる
"set clipboard=unnamed

"---------------------------
" Start Neobundle Settings.
"---------------------------
"
set nocompatible
filetype plugin indent off
set runtimepath+=~/.vim/bundle/neobundle.vim
call neobundle#begin(expand('~/.vim/bundle'))

NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'kannokanno/previm'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'go', {'type' : 'nosync'}
NeoBundle 'dgryski/vim-godef'
" 未インストールのプラグインがある場合、インストールするかどうかを尋ねてくれるようにする設定
" 毎回聞かれると邪魔な場合もあるので、この設定は任意です。
NeoBundleCheck
call neobundle#end()
filetype plugin indent on


"---------------------------
" Start go Settings.
"---------------------------

set rtp^=$GOROOT/misc/vim
set rtp^=$GOPATH/src/github.com/nsf/gocode/vim


if exists("g:did_load_filetypes")
    filetype off
    filetype plugin indent off
endif
set path+=$GOPATH/src/**
filetype plugin indent on
au FileType go compiler go
let g:gofmt_command = 'goimports'
exe "set rtp+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
set completeopt=menu,preview

"---------------------------
" Start markdown Settings.
"---------------------------
au BufRead,BufNewFile *.md set filetype=markdown
augroup PrevimSettings
    autocmd!
    autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
augroup END
 
"-------------------------
" End Neobundle Settings.
"-------------------------

"-------------------------
" End Neobundle Settings.
"-------------------------
nmap gp :pc<cr>
nmap gn :nc<cr>
nmap gi :ni<cr>
nmap gI :pi<cr>
nmap gr :xccmd jumpToDefinition<cr>
