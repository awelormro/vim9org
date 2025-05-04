" vim:set fdm=marker:
" vim:set nospell:
if !has('vim9script')
  finish
endif
vim9script
# Parser creation {{{
export def Parser_for_tags()
  # Variable declarations {{{
  var linec = '' # Used
  var linetotal = line('$') # used
  var tokens_line = [] # Used
  var i = 0 # Used
  var type_tag = '' # Used
  var tags_line = []
  if !exists('b:buffer_tags')
    b:buffer_tags = [] # Used
  endif
  # }}}
  # if exists('g:org_tags')
  # endif
  # Check all lines {{{
  # Structure for all tag: {{{
  # { name_tag:tagname, 
  #   kind_tag: 'single', 'hierarchy_leader', 'hierarchy_follow', 'excludant'
  #   excludant_tags: [list with all the tags that are mutually excludant]
  #   hierarchy_leader: if is inherted by another, is indicated
  #   hierarchy_following: [list of all tags that are after a hierarchy, for
  #                         main tags]
  # }
  # }}}
  while i < linetotal
    linec = getline(i)
    # stop loop if line is a header {{{
    if linec =~ '^\*'
      echo linec
      break
    # }}}
    elseif linec =~ '^#+TAGS:\s'
      tokens_line = Tokenize_lines(linec)
      tags_line = 
      add(b:buffer_tags, tokens_line)
    endif
    i += 1
  endwhile
  # }}}
enddef
# }}}
# Auxiliar functions for parser {{{
def Tokenize_lines(line_cont: string): list<any> # {{{
  # Variable declarations {{{
  var tokens_list = []
  var tokens = []
  var i = 0
  var word_started = false
  var word_token = ''
  var in_group = false
  var in_hierarchy = false
  var mapping = false
  var line_content = trim(line_cont[7 :])
  var line_length = len(line_content)
  var spl_line = []
  # }}}
  while i < line_length
    # Check parentheses, brackets and curly brackets {{{
    # Curly brackets {{{
    if line_content[i] == "{"
      if in_group
        add(tokens, ['error', '{'])
      endif
      in_group = true
      add(tokens, ['start_group', '{'])
      i += 1
      continue
    elseif line_content[i] == "}"
      if !in_group
        add(tokens, ['error', '}'])
      endif
      add(tokens, ['end_group', '}'])
      if word_started
        add(tokens, ['word', word_token])
        word_token = ''
        word_started = false
      endif
      i += 1
      continue
    # }}}
    # Square brackets {{{
    elseif line_content[i] == "["
      if in_hierarchy
        add(tokens, ['error', '['])
        i += 1
        continue
      endif
      in_hierarchy = true
      add(tokens, ['start_hierarchy', '['])
      i += 1
      continue
    elseif line_content[i] == "]"
      if !in_hierarchy
        add(tokens, ['error', "]"])
      endif
      in_hierarchy = false
      if word_started
        add(tokens, ['word', word_token])
        word_token = ''
        word_started = false
      endif
      add(tokens, ['end_hierarchy', ']'])
      i += 1
      continue
    # }}}
    # Parentheses {{{
    elseif line_content[i] == "("
      if mapping
        add(tokens, ['error', '('])
      endif
      mapping = true
      word_token ..= line_content[i]
      i += 1
      continue
    elseif line_content[i] == ")"
      if !mapping
        add(tokens, ['error', ")"])
      endif
      mapping = false
      i += 1
      continue
    # }}}
    # }}}
    # Word similar processor {{{
    elseif line_content[i] =~ '\w'
      if !word_started
        word_started = true
      endif
      word_token ..= line_content[i]
      i += 1
      continue
    elseif line_content[i] =~ '\s'
      if word_started
        add(tokens, ['word', word_token])
        word_token = ''
        word_started = false
      endif
      i += 1
      continue
    elseif line_content[i] == "@"
      if word_started
        add(tokens, ['error', "@"])
        i += 1
        continue
      endif
      word_started = true
      word_token ..= line_content[i]
      i += 1
      continue
    elseif line_content[i] == ":"
      if i == 0
        echo line_content
        spl_line = split(line_content[1 : -1], ':')
        for wtoken in spl_line
          add(tokens, ['word', wtoken])
        endfor
        i = line_length
        continue
      else
        add(tokens, ['colon', ':'])
        i += 1
        continue
      endif
    else
      add(tokens, ['error', line_content[i]])
      i += 1
      continue
    # }}}
    endif
  endwhile
  # Add in case a last element {{{
  if word_started && word_token != ''
    add(tokens, ['word', word_token])
  endif
  # }}}
  echo tokens
  return tokens
enddef # }}}
def Extract_tags(tokens: list<any>): list<any> # {{{
  # Variable declarations {{{
  var list_kinds = []
  var hierarchy_leader = true
  var value_kinds = []
  var list_tags = []
  var i = 0
  var len_kinds = 0
  var hierarchy = false
  var excludant = false
  # }}}
  # Read all conditions, echo error if not conditions {{{
  for token in tokens
    add(list_kinds, token[0])
    add(value_kinds, token[1])
  endfor
  len_kinds = len(list_kinds)
  if index(list_kinds, 'error')
    echoerr 'Check syntax for tags line'
    return list_tags
  endif
  # }}}
  # Generate dictionary for easy  {{{
  for kind in list_kinds
    i += 1
  endfor
  # }}}
  return list_tags
enddef # }}}
# }}}
