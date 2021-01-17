" vim-uncrustify
"
" Author: Yecheng Fu <cofyc.jackson@gmail.com>
"

" Define default "g:uncrustify_debug" {{{2
if !exists("g:uncrustify_debug")
  let g:uncrustify_debug = 0
endif

" temporary file for content
if !exists('g:tmp_file_uncrustify')
  let g:tmp_file_uncrustify = fnameescape(tempname())
endif

" Specify path to your Uncrustify configuration file.
let g:uncrustify_cfg_file_path =
    \ shellescape(fnamemodify('~/.uncrustify.cfg', ':p'))

" Function: s:UncrustifyDebug(level, text) {{{2
"
" Output debug message, if this message has high enough importance.
"
function! s:UncrustifyDebug(level, text)
  if (g:uncrustify_debug >= a:level)
    echom "uncrustify: " . a:text
  endif
endfunction


" Don't forget to add Uncrustify executable to $PATH (on Unix) or
" %PATH% (on Windows) for this command to work.
" http://stackoverflow.com/a/15513829/288089
" Restore cursor position, window position, and last search after running a
" command.
func! Uncrustify(...)
  let l:lang = get(a:000, 0, 'c')
  let l:start = get(a:000, 1, '1')
  let l:end = get(a:000, 2, '$')

  " Save the last search.
  let search = @/

  " Save the current cursor position.
  let cursor_position = getpos('.')

  " Save the current window position.
  normal! H
  let window_position = getpos('.')
  call setpos('.', cursor_position)

  " Get content which need to format
  let content = getline(l:start, l:end)

  " Length of lines before formating
  let lines_length = len(getline(l:start, l:end))

  " Write content to temporary file
  call writefile(content, g:tmp_file_uncrustify)
  let l:tmp_file_uncrustify_arg = s:quote(g:tmp_file_uncrustify)

  let cmd = "uncrustify -q -l " . l:lang . " --frag -c " . g:uncrustify_cfg_file_path . " -f " . l:tmp_file_uncrustify_arg

  call s:UncrustifyDebug(2, "cmd: ".cmd)
  let result = system(cmd)
  call s:UncrustifyDebug(2, "shell_error: ". v:shell_error)

  if v:shell_error == 0
    let lines_uncrustify = split(result, "\n")
    silent exec l:start.",".l:end."j"
    call setline(l:start, lines_uncrustify[0])
    call append(l:start, lines_uncrustify[1:])
  else
    echom "uncrustify: failed to run, exit code: " . v:shell_error
  endif

  " Restore the last search.
  let @/ = search

  " Restore the previous window position.
  call setpos('.', window_position)
  normal! zt

  " Restore the previous cursor position.
  call setpos('.', cursor_position)
endfunc

" Quoting string
" @param {String} str Any string
" @return {String} The quoted string
func! s:quote(str)
  return '"'.escape(a:str,'"').'"'
endfun

func! RangeUncrustify(language) range
  return call('Uncrustify', extend([a:language], [a:firstline, a:lastline]))
endfunc
