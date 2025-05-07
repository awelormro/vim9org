" vim:set fdm=marker:
" vim:set nospell:
" Legacy strings {{{
if !has('vim9script')
  finish
endif
" }}}
" vim 9 script section {{{
vim9script
# Parsers {{{
export def Tag_parsing_header(): list<any> # {{{
  var tags_header = []
  var i = 0
  var cont_line = ''
  var totlines = line('$')
  while i < totlines
    i += 1
    if getline(i) =~ '^\*'
      return tags_header
    else
      cont_line = getline(i)
      if cont_line =~ "#+TAGS: "
        tags_line = Tags_parser_line(getline(i))
        tags_header += tags_line
      endif
      i += 1
    endif
  endwhile
  return tags_header
enddef # }}}
export def Tags_parser_line(lin: string): list<any> # {{{
  var tags = []
  var all_tags_line = []
  var token_kinds = []
  var content_tokens = []
  var i = 0
  var string_to_tokenize = trim(lin[ 7 : ])
  echo string_to_tokenize
  var tokens = Generate_tokens(string_to_tokenize)
  var filtered_tokens = filter(copy(tokens), 'v:val[0] != "space"')
  # echo filtered_tokens
  var len_tokens = len(filtered_tokens)
  while i < len_tokens
    if tokens[i][0] == 'opcurbracket'
      # echo 'start exclusive tags at ' .. i .. ' pos'
      tags = Parse_excludant(filtered_tokens, i)
      add(all_tags_line, tags[0])
      i = tags[1]
      continue
    elseif tokens[i][0] == 'opsqbracket'
      echo 'start hierarchy tags'
    #   tags = Parse_hierarchy_tags(tokens, i)
    #   add(all_tags_line, tags[0])
    #   i = tags[1]
    #   continue
    # elseif tokens[i][0] == 'word'
    #   tags = Parse_regular(tokens, i)
    #   add(all_tags_line, tags[0])
    #   i = tags[1]
    #   continue
    # elseif tokens[i][0] == 'space'
    #   i += 1
    #   continue
    # elseif tokens[i][0] == 'colon'
    #   Parse_regular_colon_sep(tokens, i)
    #   add(all_tags_line, tags[0])
    #   i = tags[1]
    #   continue
    endif
    i += 1
  endwhile
  return all_tags_line
enddef # }}}
def Parse_regular_colon_sep(tokens: list<any>, pos: number): list<any> # {{{
enddef # }}}
def Parse_regular(tokens: list<any>, pos: number): list<any> # {{{
  var tags = []
  var i = pos
  return [tags, i]
enddef # }}}
def Parse_excludant(tokens: list<any>, pos: number): list<any> # {{{
  # { tagmain: tag1 tag2 ... }
  # Variable declarations {{{
  var tags = []
  var words = []
  var kinds = []
  var i = pos
  var j = 0
  # echo i
  echo tokens[pos]
  var tokens_pos = tokens[pos - 1 : - 1]
  echo tokens_pos
  # }}}
  while j < len(tokens_pos)
    add(words, tokens_pos[j][1])
    add(kinds, tokens_pos[j][0])
    j += 1
  endwhile 
  var close_excludant = index(kinds, 'clcurbracket', pos)
  var list_logic_words = words[pos : close_excludant]
  var list_logic_kinds = kinds[pos : close_excludant]
  echo list_logic_words
  echo list_logic_kinds
  echo words
  echo kinds
  return [[], i + 1]
enddef # }}}
def Parse_hierarchy_tags(tokens: list<any>, pos: number): list<any> # {{{
  var tags = []
  var i = pos
  return [tags, i]
enddef # }}}
# }}}
# Tokenizator {{{
# Main tokenizer {{{
export def Generate_tokens(lin: string): list<any>
  var tokens = []
  var token = []
  var aux_token = []
  var i = 0
  var len_line = len(lin)
  # echo lin
  while i < len_line
    if lin[i] =~ '\s'
      aux_token = Space_token(lin, i)
      token = aux_token[0]
      i = aux_token[1]
      add(tokens, token)
    elseif lin[i] =~ '\a'
      aux_token = Token_word(lin, i)
      token = aux_token[0]
      i = aux_token[1]
      add(tokens, token)
    elseif lin[i] =~ '\d'
      aux_token = Token_number(lin, i)
      token = aux_token[0]
      i = aux_token[1]
      add(tokens, token)
    else
      aux_token = Token_symbol(lin[i], i)
      token = aux_token[0]
      i = aux_token[1]
      add(tokens, token)
    endif
    # echo token
  endwhile
  return tokens
enddef # }}}
# Auxiliar functions for tokenization {{{
def Token_word(line: string, pos: number): list<any> # Tokenization for words {{{
  var i = pos
  var word = ''
  var len_word = len(line)
  var token = []
  while i < len_word
    if line[i] !~ '\a'
      return [['word', word], i]
    elseif i == len_word - 1
      word ..= line[i]
      return [['word', word], i + 1]
    else
      word ..= line[i]
      i += 1
    endif
  endwhile
  return token
enddef # }}}
def Space_token(line: string, pos: number): list<any> # Space tokenization {{{
  var token = []
  var i = pos
  var len_word = len(line)
  var len_space = 0
  while i < len_word
    if line[i] =~ '\s'
      len_space += 1
      i += 1
      continue
    else
      return [['space', len_space], i]
    endif
  endwhile
  return token
enddef # }}}
def Token_number(line: string, pos: number): list<any> # Tokenization for numbers {{{
  var token = []
  var i = pos
  var len_line = len(line)
  while i < len_line
    if line[i] =~ '\d'
      i += 1
    else
      return [['number', line[pos : i - 1]], i]
    endif
  endwhile
  return token
enddef # }}}
def Token_symbol(symbol: string, pos: number): list<any> # {{{
  var info = []
  var token = []
  var i = pos
  if symbol == '"'
    info = ['dquote', '"']
  elseif symbol == "'"
    info = ['squote', "'"]
  elseif symbol == "@"
    info = ['at', symbol]
  elseif symbol == "#"
    info = ['hashtag', symbol]
  elseif symbol == "$"
    info = ['dollar', symbol]
  elseif symbol == "%"
    info = ['perc', symbol]
  elseif symbol == "&"
    info = ['ampers', symbol]
  elseif symbol == "*"
    info = ['asterisk', symbol]
  elseif symbol == "("
    info = ['opparentheses', symbol]
  elseif symbol == ")"
    info = ['clparentheses', symbol]
  elseif symbol == "["
    info = ['opsqbracket', symbol]
  elseif symbol == "]"
    info = ['clsqbracket', symbol]
  elseif symbol == "{"
    info = ['opcurbracket', symbol]
  elseif symbol == "}"
    info = ['clcurbracket', symbol]
  elseif symbol == "-"
    info = ['hyphen', symbol]
  elseif symbol == "_"
    info = ['underscore', symbol]
  elseif symbol == "\\"
    info = ['backslash', symbol]
  elseif symbol == "/"
    info = ['slash', symbol]
  elseif symbol == "+"
    info = ['plus', symbol]
  elseif symbol == ","
    info = ['comma', symbol]
  elseif symbol == "."
    info = ['period', symbol]
  elseif symbol == ";"
    info = ['semicolon', symbol]
  elseif symbol == ":"
    info = ['colon', symbol]
  elseif symbol == ">"
    info = ['more_than', symbol]
  elseif symbol == "<"
    info = ['less_than', symbol]
  elseif symbol == "="
    info = ['equal', symbol]
  else
    info = ['misc', symbol]
  endif
  token = [info, i + 1]
  return token
enddef # }}}

# }}}
# }}}
# }}}
