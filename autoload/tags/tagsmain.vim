vim9script
# vim: set fdm=marker:
# vim: set nospell:
import autoload "submenus/submenus.vim" as sbmnu
export def CreateTags() # {{{
  if !exists('b:orgtags')
    b:orgtags = [ 'noexport', 'todo', 'doing', 'done' ]
  endif
  if index(b:orgtags, 'noexport') < 0
    b:orgtags = extend(['noexport'], b:orgtags)
  endif
  sbmnu.CountAllHeaders()
  var unduptags = []
  var buffertags = CheckIfExistTagLine()
  # echo buffertags
  b:orgtags = extend( b:orgtags, buffertags )
  buffertags = ObtainTagsInTitles( b:alltitles )
  b:orgtags = extend( b:orgtags, buffertags )
  # echo b:orgtags
  # Remove duplicates
  for tag in b:orgtags
    if index(unduptags, tag) < 0
      add(unduptags, tag)
    endif
  endfor
  b:orgtags = unduptags
  # var unduplist = filter(copy(buffertags), 'index(buffertags, v:val, v:key + 1) == - 1')
enddef # }}}
def CheckIfExistTagLine(): list<any> # {{{
  var i = 1
  var contline = ''
  var conttags = []
  var exittags = []
  while i < line('$')
      contline = getline(i)
      if contline =~ '^\*'
        # echo 'Titles started. Preamble finished'
        # Each tag must have the hierarchy in case of need, 
        # TODO: Fix the capability to add org hierarchy and exclusion
        break
      else
        if contline =~ "#+TAGS: "
          # if contline =~ '{ \a* :'
          #   conttags = split(contline, "{")
          #   echo "Main tags added"
          # elseif count(contline, ':') > 1
          if count(contline, ':') > 1
            conttags = split(contline)
            conttags = split(conttags[1], ':')
          else
            conttags = split(contline)
            conttags = conttags[1 : ]
          endif
          extend(exittags, conttags)
        endif
      endif
      i += 1
  endwhile
  # var tagsline = search("#+TAGS: ")
  return exittags
enddef # }}}
export def ObtainTagsInTitles(heads: list<any>): list<any> # {{{
  var tagsintitles = []
  var tagtitle = []
  for title in heads
    tagtitle = SupressTitleAndCheckTags(title[0])
    tagsintitles = extend(tagsintitles, tagtitle)
  endfor
  # echo tagsintitles
  return tagsintitles
enddef # }}}
def SupressTitleAndCheckTags(otit: string ): list<any> # {{{
  var titletags = []
  var startpos = match(otit,  ' :\w\+:.*$')
  # echo otit[ startpos : ]
  # echo startpos
  if startpos > 0
    var stringtags = otit[ startpos + 2 : ]
    titletags = split(stringtags, ":")
  endif
  # echo titletags
  return titletags
enddef # }}}
export def OrgCompletionTags(): string # {{{
  CreateTags()
  call complete(col('.'), b:orgtags )
  return ''
enddef # }}}
export def TagsBufferCreation() # {{{
  # Obtain tags in file and and the tags in the title {{{
  var newtags = b:orgtags
  var inheadertags = GetHeaderInfoAndTags()
  var currenttags = []
  if len(inheadertags) > 0
    currenttags = inheadertags[-1]
  endif
  # }}}
  CreateSplitBelowbufferBuffer()
  # Set current header {{{
  setline(1, 'Tags in header: ' .. join(currenttags, ', '))
  setline(2, 'Tags: ')
  # }}}
  # Buffer Variables {{{
  b:currenttags = currenttags
  b:orgsearchtags = newtags
  b:inheadertags = inheadertags
  var i = 3
  # }}}
  # Add tags to screen {{{
  for orgtag in b:orgsearchtags
    setline(i, orgtag )
    i += 1
  endfor
  cursor(2, 6)
  # }}}
  OrgSearcherMaps()
enddef # }}}
# Actions to make in the buffer creation {{{
def ConfirmSelection() # {{{
  # var pendejada = input('Estás en modo' .. mode())
  var oselection = ''
  if line('.') > 2
    oselection = getline('.')
    if !empty(oselection)
      if index(b:currenttags, oselection) > -1
        remove(b:currenttags, index(b:currenttags, oselection))
      else
        add(b:currenttags, oselection)
      endif
      if index(b:orgsearchtags, oselection) < 0
        add(b:orgsearchtags, oselection)
      endif
      setline(1, 'Tags in header: ' .. join(b:currenttags, ', '))
    endif
  elseif line('.') == 2
    oselection = getline('.')[6 :]
    if !empty(oselection)
      if index(b:currenttags, oselection) > -1
        remove(b:currenttags, index(b:currenttags, oselection))
      else
        add(b:currenttags, oselection)
      endif
      if index(b:orgsearchtags, oselection) < 0
        add(b:orgsearchtags, oselection)
      endif
      setline(1, 'Tags in header: ' .. join(b:currenttags, ', '))
    endif
  endif
enddef # }}}
def Addnewtag() # {{{
  var linec = getline(2)
  var tagslist = []
  linec = linec[6 :]
  if count(linec, ',')
    tagslist = split( trim( tagslist ),  ', ')
  else
    tagslist = [trim( tagslist )]
  endif
enddef # }}}
def QuitAndReplace() # {{{
  var tagstoadd = b:currenttags
  var newtagstoadd = []
  var i = 0
  while i < len(tagstoadd) 
    if !empty(tagstoadd[i]) && tagstoadd[i] !~ '^\s*$'
      add(newtagstoadd, tagstoadd[i])
    endif
    i += 1
  endwhile
  var headertoreplace = b:inheadertags
  bd!
  # echo headertoreplace
  var contheadertoreplace = getline(headertoreplace[0])
  if count(contheadertoreplace, ':') > 1 && len(newtagstoadd) > 0
    # contheadertoreplace = substitute(contheadertoreplace,   contheadertoreplace[headertoreplace[2] + 1 :], ':' .. join(newtagstoadd, ':') .. ':', '')
    contheadertoreplace = trim(contheadertoreplace[: match(contheadertoreplace,  ' :\w\+:.*$')])
    setline( headertoreplace[0], contheadertoreplace .. repeat(' ', &tw - len(contheadertoreplace)) .. ':' 
             .. join(newtagstoadd, ':') .. ':' )
  elseif len(newtagstoadd) == 0
    setline(headertoreplace[0], trim(contheadertoreplace[ : match(contheadertoreplace,  ' :\w\+:.*$') ]))
  else
    setline(headertoreplace[0], trim(contheadertoreplace) .. 
                                repeat(' ', &tw - len(trim(contheadertoreplace))) .. ':' 
                                .. join(newtagstoadd, ':') .. ':')
  endif
  # echo contheadertoreplace
enddef # }}}
def GetHeaderInfoAndTags(): list<any> # {{{
  var lnum = line('.')
  var lcont = getline(lnum)
  var i = lnum
  while i > 0
    lcont = getline(i)
    if stridx(lcont, '*') == 0
      # echo 'line is header'
      break
    else
      lcont = ''
    endif
    i -= 1
  endwhile
  var infotagshead = []
  var startpos = match(lcont,  ' :\w\+:.*$')
  if !empty(lcont) && startpos > 0
    # infotagshead = split( lcont )
    infotagshead = split(lcont[startpos : ], ':')
    infotagshead = [ i, lcont, startpos, infotagshead ]
    # infotagshead[-1] = split(infotagshead[-1], ':')
  else
    infotagshead = [ i, lcont, -1, [] ]
    return infotagshead
  endif
  return infotagshead
enddef # }}}
def RefillTagSpace() # {{{
  var howtoswing = mode()
    # Detect if line starts with the tags line {{{
    var i = 3
    if len(getline(2)) > 6 && getline(2)[: 5] != 'Tags: '
      # echo 'No title tags, added'
      setline(1, 'Tags: ')
      # execute ':' .. string(2) .. ',' .. string( line('$') ) .. 'd'
    endif
    # }}}
    # Fill the dictionary {{{
    # b:currsearch = matchfuzzy(b:orgsearchtags, getline(1)[6 :])
    if empty(getline(2)[6 :]) || getline(2)[6 :] =~ '^\s*$'
      echo 'nothing added, now fill all tags'
      b:currsearch = b:orgsearchtags
    else
      b:currsearch = matchfuzzy(b:orgsearchtags, getline(2)[6 :])
    endif
    # }}}
    # if The length of the file is larger than the desired, delete {{{
    if line('$') > 3
      execute ':' .. string(i) .. ',' .. string( line('$') ) .. 'd'
    endif
    # }}}
    for searchres in b:currsearch
      append( line('$'), searchres )
    endfor
    cursor(2, col('$'))
    if howtoswing !~ 'n'
      startinsert
    endif
    # startinsert
    # call feedkeys('A', 'n')
enddef # }}}
def CreateSplitBelowbufferBuffer() # {{{
  var splitstatus = &splitbelow
  if !&splitbelow
    execute 'set splitbelow'    
  endif
  :10new
  if !splitstatus
    execute 'set nosplitbelow'
  endif
enddef # }}}
def AddContentInSearchBar() # {{{
  var contline = getline(2)[6 :]
enddef
# }}}
def OrgSearcherMaps() # {{{
  set filetype=orgsearcher
  # b:headertoreplace = inheadertags
  command -buffer TagsConfirmSelection ConfirmSelection()
  command -buffer TagsGenerateAndSubstitute QuitAndReplace()
  command -buffer TagsAddSearchTag AddContentInSearchBar()
  command -buffer RefillTagsSpace RefillTagSpace()
  inoremap <buffer><expr> <Backspace> line('.') == 2 && col('.') > 7 ? '<Backspace>' : ''
  inoremap <buffer><expr> <CR> line('.') > 1 ? '<Esc>:TagsConfirmSelection<CR>' : ''
  nnoremap <buffer> <Tab> <Down>
  nnoremap <buffer> <S-Tab> <Up>
  # inoremap <buffer><expr> <CR> line('.') == 2 ? '<Esc>:TagsConfirmSelection<CR>' : ''
  nnoremap <buffer> <CR> :TagsConfirmSelection<CR>
  nnoremap <buffer> q :TagsGenerateAndSubstitute<CR>
  autocmd TextChanged,TextChangedI,TextChangedP <buffer> RefillTagSpace()
enddef # }}}
#  }}}
