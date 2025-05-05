" vim:set fdm=marker:
" vim:set nospell:
" Legacy strings {{{
if !has('vim9script')
  finish
endif
" }}}
" vim 9 script section {{{
vim9script
# Main tokenizer {{{
export def Generate_tokens(line: list<any>): list<any>
  var tokens = []
  var token = []
  var i = 0
  var  = 
  return tokens
enddef
# }}}
# Auxiliar functions for tokenization {{{
def Word_token(line: list<any>, pos: number): list<any>
  var word = ''
  var i = 0
  var token = []
  return token
enddef
# }}}
# }}}
