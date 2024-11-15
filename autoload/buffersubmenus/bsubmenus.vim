vim9script
# vim: set fdm=marker:
# vim: set nospell:
#
export def CreateBuffer(bufft : string, bufhght: string, bcontents: dict<any>) # {{{
  var spltblw = &splitbelow
  exe 'set splitbelow'
  exe bufhght .. ':new'
  if !spltblw
    exe 'set nosplitbelow'
  endif
enddef # }}}
def HeaderContent(listheads: list<any>) # {{{
  var i = 0
  while i <= len(listheads)
    setline(listheads[i], i + 1)
    i += 1
  endwhile
  b:headerlen = len(listheads)
enddef # }}}
def SetMappings(lstmaps: dict<any>, mapstype: string) # {{{
  var num_mapping = 0
  var kind_map = ''
  if mapstype == 'n'
    kind_map = 'nnoremap'
  elseif mapstype == 'i'
    kind_map = 'inoremap'
  else
    kind_map = 'nnoremap'
  endif
  for mapping in keys(lstmaps)
    exe kind_map .. ' ' .. lstmaps[mapping]['key'] .. ' ' .. lstmaps[mapping]['action']
  endfor
enddef # }}}
