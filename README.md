# vim-uncrustify

## Installation

### Installing with pathogen

```
cd ~/.vim/bundle
git clone https://github.com/Cofyc/vim-uncrustify.git
```

## Usage

Add these in your `.vimrc` file:

```
autocmd FileType c noremap <buffer> <c-f> :call Uncrustify('c')<CR>
autocmd FileType c vnoremap <buffer> <c-f> :call RangeUncrustify('c')<CR>
autocmd FileType cpp noremap <buffer> <c-f> :call Uncrustify('cpp')<CR>
autocmd FileType cpp vnoremap <buffer> <c-f> :call RangeUncrustify('cpp')<CR>
```

## References

- https://github.com/maksimr/vim-jsbeautify
