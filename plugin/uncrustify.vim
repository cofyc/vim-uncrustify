" vim-uncrustify
"
" Author: Yecheng Fu <cofyc.jackson@gmail.com>
"

" Define default "g:uncrustify_debug" {{{2
if !exists("g:uncrustify_debug")
  let g:uncrustify_debug = 0
endif

" Specify path to your Uncrustify configuration file.
let g:uncrustify_cfg_file_path = "auto"

" Log debug message
function! s:UncrustifyDebug(text)
  if g:uncrustify_debug
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
  let l:tmpfile = tempname() . '.' . l:lang
  call s:UncrustifyDebug("tmpfile: " . l:tmpfile)
  call writefile(content, l:tmpfile)

  " Detect configuration file
  let l:cfgfile = ""
  if g:uncrustify_cfg_file_path == "auto"
    let l:cwdcfg = ".uncrustify.cfg"
    let l:homecfg = shellescape(fnamemodify('~/.uncrustify.cfg', ':p'))
    if filereadable(l:cwdcfg)
      let l:cfgfile = l:cwdcfg
    elseif filereadable(l:homecfg)
      let l:cfgfile = l:homecfg
    endif
  else
    let l:cfgfile = g:uncrustify_cfg_file_path
  endif

  let cmd = "uncrustify -q -l " . l:lang . " -c " . l:cfgfile . " -f " . l:tmpfile . " -o " . l:tmpfile

  call s:UncrustifyDebug("cmd: ".cmd)
  call system(cmd)
  call s:UncrustifyDebug("shell_error: ". v:shell_error)

  if v:shell_error == 0
    let lines_uncrustify = readfile(l:tmpfile)
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

  " Delete the temporary file
  call delete(l:tmpfile)
endfunc

func! RangeUncrustify(language) range
  return call('Uncrustify', extend([a:language], [a:firstline, a:lastline]))
endfunc
