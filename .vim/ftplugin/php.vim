""" File ~/.vim/ftplugin/php.vim
""" PHP specific settings.
" General settings
setlocal expandtab
setlocal tabstop=4

" General key binding
noremap L f$
noremap H F$
nnoremap <Leader>4 F4r$A

" dictionary
autocmd FileType php :set dictionary=$HOME/.vim/dict/php.dict

" make
set makeprg=php\ -l\ %

" Extract-Method refactoring
vmap \em :call ExtractMethod()<CR>
function! ExtractMethod() range
  let name = inputdialog("Name of new method:")
  exe ":set paste"
  '<
  exe "normal! O\<Tab>private function " . name ."() \<CR>\<Tab>{\<Esc>"
  '>
  exe "normal! o\<Tab>\<Tab>return ;\<CR>\<Tab>}\<Esc>k"
  s/return/\/\/ return/ge
  normal! j%
  normal! kf(
  exe "normal! yyPi// = \<Esc>wdwdwA\<BS>;\<Esc>"
  normal! ==
  normal! j0w
  exe "normal! Vj%dk]Mo\<Esc>p"
  exe ":call PhpDocSingle()"
  exe ":set nopaste"
endfunction
