" vim-uncrustify
"
" Author: Yecheng Fu <cofyc.jackson@gmail.com>
"

" temporary file for content
if !exists('g:tmp_file_uncrustify')
  let g:tmp_file_uncrustify = fnameescape(tempname())
endif

" Specify path to your Uncrustify configuration file.
let g:uncrustify_cfg_file_path =
    \ shellescape(fnamemodify('~/.uncrustify.cfg', ':p'))

" http://stackoverflow.com/a/15513829/288089
" Restore cursor position, window position, and last search after running a
" command.
func! s:Preserve(command)
  " Save the last search.
  let search = @/

  " Save the current cursor position.
  let cursor_position = getpos('.')

  " Save the current window position.
  normal! H
  let window_position = getpos('.')
  call setpos('.', cursor_position)

  " Execute the command.
  execute a:command

  " Restore the last search.
  let @/ = search

  " Restore the previous window position.
  call setpos('.', window_position)
  normal! zt

  " Restore the previous cursor position.
  call setpos('.', cursor_position)
endfunc

" Don't forget to add Uncrustify executable to $PATH (on Unix) or 
" %PATH% (on Windows) for this command to work.
func! Uncrustify(language)
  call s:Preserve(':silent %!uncrustify'
      \ . ' -q '
      \ . ' -l ' . a:language
      \ . ' -c ' . g:uncrustify_cfg_file_path)
endfunc

" Quoting string
" @param {String} str Any string
" @return {String} The quoted string
func! s:quote(str)
  return '"'.escape(a:str,'"').'"'
endfun

func! Uncrustify2(...)
  let l:lang = get(a:000, 0, 'c')
  let l:line1 = get(a:000, 1, '1')
  let l:line2 = get(a:000, 2, '$')

  " Get content from the files
  let content = getline(l:line1, l:line2)

  " Length of lines before beautify
  let lines_length = len(getline(l:line1, l:line2))

  " Write content to temporary file
  call writefile(content, g:tmp_file_uncrustify)
  let l:tmp_file_uncrustify_arg = s:quote(g:tmp_file_uncrustify)

  let cmd = "uncrustify -q -l " . l:lang . " --frag -c " . g:uncrustify_cfg_file_path . " -f " . l:tmp_file_uncrustify_arg
  let result = system(cmd)
  let lines_uncrustify = split(result, "\n")

  if !len(lines_uncrustify)
      return result
  endif

  silent exec line1.",".line2."j"
  call setline(line1, lines_uncrustify[0])
  call append(line1, lines_uncrustify[1:])
  return result
endfunc

func! RangeUncrustify(language) range
  return call('Uncrustify2', extend([a:language], [a:firstline, a:lastline]))
endfunc
