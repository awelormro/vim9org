" vim:set fdm=marker:
" vim:set nospell:
" Legacy strings {{{
if !has('vim9script')
  finish
endif
" }}}
" vim 9 script section {{{
vim9script
import autoload "v9sc/tokenizers.vim" as tokenizer
# Parsers {{{
# Error list on tags{{{
# E001: Invalid tags syntax
# E002: Unclosed tags hierarchy
# }}}
export def Tag_parsing_header(): list<any> # {{{
  var tags_header = []
  var tags_line = []
  var i = 0
  var cont_line = ''
  var totlines = line('$')
  while i < totlines
    i += 1
    if getline(i) =~ '^\*'
      break
      # return tags_header
    else
      cont_line = getline(i)
      if cont_line =~ "#+TAGS: "
        tags_line = Tags_parser_line(getline(i))
        tags_header += tags_line
      endif
      i += 1
    endif
  endwhile
  b:org_tags = tags_header
  return tags_header
enddef # }}}
export def Tags_parser_line(lin: string): list<any> # {{{
  # Variable declarations {{{
  var tokens = tokenizer.General_Tokenizer(lin)
  var tokens_wo_head = tokens[5 :]
  var joined_tokens = Parse_words(tokens_wo_head, 0)
  var work_tokens = copy(filter(joined_tokens, 'v:val[0] !~ "space"' ))
  echo work_tokens
  var lentokens = len(work_tokens)
  var begpos = -1000
  var endpos = -1000
  var tags_add = []
  var exit_tags = []
  var i = 0
  # }}}
  # Loop for sparse tokens {{{
  while i <= lentokens - 1
    if work_tokens[i][0] == 'tag'
      tags_add = Parse_regular(work_tokens, i, 'word')
      exit_tags += [tags_add[0]]
      i = tags_add[1]
      echo tags_add
      continue
    elseif work_tokens[i][0] == 'opcurbracket'
      tags_add = Parse_excludant(work_tokens, i)
      echo tags_add
      exit_tags += tags_add[0]
      i = tags_add[1]
      i += 1
      continue
    elseif work_tokens[i][0] == 'opsqbracket'
      tags_add = Parse_hierarchy(work_tokens, i)
      exit_tags += tags_add[0]
      i = tags_add[1]
      continue
    elseif work_tokens[i][0] == 'colon'
      tags_add = Parse_alltags(work_tokens, i)
      exit_tags += [tags_add[0]]
      i = tags_add[1]
      continue
    else
      echoerr 'E001: Invalid tags syntax'
      i += 1
    endif
  endwhile
  # }}}
  return exit_tags
enddef # }}}
def Parse_alltags(tokens: list<any>, pos: number): list<any> #  {{{
  # echo tokens
  var i = pos + 1
  var colon = false
  var word = false
  var export_string = ''
  var lentokens = len(tokens)
  var tag_export = {"name": '',
    'kind': 'alltags',
    'mapping': '',
    'before': '',
    'excludant': [],
    'after': []
  }
  for tag in tokens
    if tag[0] == 'colon' || tag[0] == 'tag'
      export_string ..= tag[1]
    else
      echoerr 'not valid syntax'
      return [tag_export, len(tokens)]
    endif
  endfor
  tag_export["name"] = export_string
  return [tag_export, len(tokens) ]
enddef
# }}}
def Parse_words(tokens: list<any>, pos: number): list<any> #{{{
  var i = pos
  var word_token = ''
  var token_tag = []
  var tokens_exit = []
  var valid_symbols = ['number', 'word', 'at', 'underscore']
  var len_tokens = len(tokens)
  while i < len_tokens
    if i == len_tokens - 1
      if index(valid_symbols, tokens[i][0]) > -1
        word_token ..= tokens[i][1]
        add(tokens_exit, ['tag', word_token])
        return tokens_exit
      elseif len(word_token) > 0
        add(tokens_exit, ['tag', word_token])
        add(tokens_exit, tokens[i])
        return tokens_exit
      endif
    endif
    if index(valid_symbols, tokens[i][0]) > -1
      word_token ..= tokens[i][1]
      i += 1
      continue
    else
      if len(word_token) > 0
        add(tokens_exit, ['tag', word_token])
        word_token = ''
        add(tokens_exit, tokens[i])
        i += 1
        continue
      else
        add(tokens_exit, tokens[i])
        i += 1
        continue
      endif
      continue
    endif
  endwhile
  return tokens_exit
enddef # }}}
def Parse_excludant(tags: list<any>, pos: number): list<any> # {{{
  var i = pos + 1
  var len_tags = len(tags)
  var exit_tags = []
  var exclusion_tags = []
  var list_exclusion = []
  var tag_generated = []
  var sep_list =  0
  if tags[i][0] == 'tag' && tags[i + 1][0] == 'colon'
    return Parse_hierarchy_excludant(tags, pos)
  endif
  while i < len_tags
    if tags[i][0] == 'clcurbracket'
      sep_list = i
      break
    elseif tags[i][0] == 'tag'
      tag_generated = Parse_regular(tags, i, 'excludant')
      add(exit_tags, tag_generated[0])
      add(list_exclusion, tag_generated[0]["name"])
      echo tag_generated[0]["name"]
      i = tag_generated[1]
      continue
    endif
  endwhile
  i = 0
  while i < len(exit_tags)
    exclusion_tags = filter(copy(list_exclusion), 'v:val != "' .. exit_tags[i]["name"] .. '"')
    exit_tags[i]['excludant'] = exclusion_tags
    i += 1
  endwhile
  return [exit_tags, i + 1]
enddef # }}}
def Parse_hierarchy_excludant(tags: list<any>, pos: number): list<any> # {{{
  var len_tags = len(tags)
  var exit_tags = []
  var i = pos + 1
  var colon = false
  var final_pos = 0
  var main_string = ''
  var exclusion_tags = []
  var tag_gen = []
  echo tags[i]
  echo tags[i + 1]
  if tags[i][0] == 'tag' && tags[i + 1][0] == 'colon'
    colon = true
    main_string = tags[i][1]
    tag_gen = Parse_regular(tags, i, 'main_hierarchy')
    add(exit_tags, tag_gen[0])
    i += 2
  else
    echoerr 'not valid position'
    return [[], len(tags) + 1]
  endif
  while i < len_tags
    if tags[i][0] == 'clcurbracket'
      final_pos = i + 1
      break
    elseif tags[i][0] == 'tag'
      tag_gen = Parse_regular(tags, i, 'less_hierarchy')
      add(exclusion_tags, tag_gen[0]["name"])
      add(exit_tags, tag_gen[0])
      i = tag_gen[1]
      continue
    else
      echoerr 'not valid position'
      return [[], len(tags) + 1]
    endif
  endwhile
  i = 0
  var final_exclusion = []
  while i < len(exit_tags)
    if i == 0
      exit_tags[i]["after"] = exclusion_tags
    else
      exit_tags[i]["excludant"] = filter(copy(exclusion_tags), 'v:val != "' .. exit_tags[i]["name"] .. '"')
      exit_tags[i]["before"] = main_string
    endif
    i += 1
  endwhile
  return [exit_tags, final_pos]
enddef # }}}
def Parse_hierarchy(tags: list<any>, pos: number): list<any> # {{{
  var exit_tags = []
  var i = pos + 1
  var pos_sqbracket = -1
  var len_tags = len(tags)
  var pos_colon = -1
  var colon = false
  var valid_start = false
  var tag_gen_list = []
  var list_before = []
  var main_string = ''
  var tag_gen = {}
  var end_tags = false
  if tags[i][0] == 'tag'
    valid_start = true
    tag_gen_list = Parse_regular(tags, i, 'main_hierarchy')
    tag_gen = tag_gen_list[0]
    main_string = tag_gen_list[0]['name']
    i = tag_gen_list[1]
    add(exit_tags, tag_gen_list[0])
  else
    echoerr 'not valid tag'
    return [[], len(tags)]
  endif
  if valid_start && tags[i][0] == 'colon'
    colon = true
    i += 1
  else
    echoerr 'not sequence for hierarchy tags'
    return [exit_tags, len(tags)]
  endif
  while i < len_tags
    if tags[i][0] == 'tag'
      tag_gen_list = Parse_regular(tags, i, 'less_hierarchy')
      add(list_before, tag_gen_list[0]["name"])
      add(exit_tags, tag_gen_list[0])
      i = tag_gen_list[1]
      continue
    elseif tags[i][0] == 'opcurbracket'
      tag_gen_list = Parse_regexp(tags, i)
      add(list_before, tag_gen_list[0]["name"])
      add(exit_tags, tag_gen_list[0])
      i = tag_gen_list[1]
      continue
    elseif tags[i][0] == 'clsqbracket'
      break
      # return [exit_tags, i + 1]
    else
      echoerr "not correct syntax"
      return [[], len(tags) + 1]
    endif
  endwhile
  exit_tags[0]["after"] = list_before
  for tag in exit_tags
    if tag["kind"] == 'less_hierarchy'
      tag["before"] = main_string
    endif
  endfor
  return [exit_tags, i + 1]
enddef # }}}
def Parse_regexp(tags: list<any>, pos: number): list<any> # {{{
  var tag_export = []
  var exit_tag = {"name": '',
    'kind': '',
    'mapping': '',
    'before': '',
    'excludant': [],
    'after': []
  }
  exit_tag["kind"] = 'regexp'
  var regexp_export = ''
  var i = pos
  var len_tags = len(tags)
  while i < len_tags
    if tags[i][0] == 'clcurbracket'
      exit_tag["name"] = regexp_export
      return [exit_tag, i + 1]
    elseif tags[i][0] == 'opcurbracket'
      i += 1
      continue
    else
      regexp_export ..= tags[i][1]
      i += 1
      continue
    endif
  endwhile
  return tag_export
enddef # }}}
def Parse_regular(tags: list<any>, pos: number, kind_tag: string): list<any> # {{{
  var tag_export = {"name": '',
    'kind': '',
    'mapping': '',
    'before': '',
    'excludant': [],
    'after': []
  }
  tag_export["name"] = tags[pos][1]
  tag_export["kind"] = kind_tag
  var i = pos
  var tag_name = ''
  var mapping = ''
  var mp = false
  var ki = kind_tag
  if pos + 3 <= len(tags) - 1
    # echo 'possible mapping'
    if tags[i + 1][0] == 'opparentheses' && 
        tags[i + 2][0] == 'tag' && 
        len(tags[i + 2][1]) == 1 && 
        tags[i + 3][0] == 'clparentheses'
      # echo 'has mapping'
      tag_export['mapping'] = tags[pos + 2][1]
      i = pos + 4
      return [tag_export, i]
    endif
  else
    return [tag_export, i + 1]
  endif
  return [tag_export, i + 1]
enddef # }}}
# }}}
