if !has('vim9script')
  finish
endif
vim9script

export def Nrrow_Obtain_lines(idx_start: number, idx_end: number)
  var content = getline(idx_start, idx_end)
  :enew
  set filetype=org.orgnrrow
  setline(1, content[0])
  if len(content) > 1
    append(1, content[1 :])
  endif
enddef
