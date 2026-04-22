" vim:set fdm=marker:
" vim:set nospell:
" Legacy strings {{{
if !has('vim9script')
  finish
endif
" }}}
vim9script

export def General_Tokenizer(line: string): list<any> # {{{
  var cont = line
  var i = 0
  var token = []
  var content = []
  var tokens = []
  var lenline = len(line)
  while i < lenline
    if line[i] =~ '\a'
      content = Token_word(line, i)
      token = content[0]
      add(tokens, token)
      i = content[1]
      continue
    elseif line[i] =~ '\d'
      content = Token_number(line, i)
      token = content[0]
      i = content[1]
      add(tokens, token)
      continue
    elseif line[i] =~ '\s'
      content = Token_space(line, i)
      token = content[0]
      i = content[1]
      add(tokens, token)
      continue
    else
      content = Token_symbol(line[i], i)
      token = content[0]
      i = content[1]
      add(tokens, token)
      continue
    endif
  endwhile
  return tokens
enddef # }}}
def Token_word(line: string, pos: number): list<any> # {{{
  var i = pos
  var lenline = len(line)
  var word = ''
  while i < lenline
    if line[i] !~ '\a'
      return [['word', word],  i]
    elseif i == lenline - 1
      word ..= line[i]
      return [['word', word], i + 1]
      i += 1
    else
      word ..= line[i]
      i += 1
    endif
  endwhile
  return []
enddef # }}}
def Token_number(line: string, pos: number): list<any> # {{{
  var i = pos
  var lenline = len(line)
  var word = ''
  while i < lenline
    if line[i] !~ '\d'
      return [['number', word],  i]
    elseif i == lenline - 1
      word ..= line[i]
      return [['number', word], i]
    else
      word ..= line[i]
      i += 1
    endif
  endwhile
  return []
enddef # }}}
def Token_space(line: string, pos: number): list<any> # {{{
  var i = pos
  var lenline = len(line)
  var len_space = 0
  while i < lenline
    if line[i] !~ '\s'
      return [['space', len_space],  i]
    elseif i == lenline - 1
      return [['space', len_space], i]
    else
      i += 1
      len_space += 1
    endif
  endwhile
  return []
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
def Token_words(line: string, pos: number): list<any> # Tokenization for words {{{
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
def Token_numbers(line: string, pos: number): list<any> # Tokenization for numbers {{{
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
def Token_symbols(symbol: string, pos: number): list<any> # {{{
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
