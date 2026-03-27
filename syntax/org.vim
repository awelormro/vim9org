" Vim syntax file
" Language:	Org
" Previous Maintainer:  Luca Saccarola <github.e41mv@aleeas.com>
" Maintainer:   This runtime file is looking for a new maintainer.
" Last Change:  2025 Aug 05
"
" Reference Specification: Org mode manual
"   GNU Info: `$ info Org`
"   Web: <https://orgmode.org/manual/index.html>

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif
let b:current_syntax = 'org'

syn case ignore

" Bold
syn region orgBold matchgroup=orgBoldDelimiter start="\(^\|[- '"({\]]\)\@<=\*\ze[^ ]" end="^\@!\*\([^\k\*]\|$\)\@=" keepend
hi def link orgBold markdownBold
hi def link orgBoldDelimiter orgBold

" Italic
syn region orgItalic matchgroup=orgItalicDelimiter start="\(^\|[- '"({\]]\)\@<=\/\ze[^ ]" end="^\@!\/\([^\k\/]\|$\)\@=" keepend
hi def link orgItalic markdownItalic
hi def link orgItalicDelimiter orgItalic

" Strikethrogh
syn region orgStrikethrough matchgroup=orgStrikethroughDelimiter start="\(^\|[ '"({\]]\)\@<=+\ze[^ ]" end="^\@!+\([^\k+]\|$\)\@=" keepend
hi def link orgStrikethrough markdownStrike
hi def link orgStrikethroughDelimiter orgStrikethrough

" Underline
syn region orgUnderline matchgroup=orgUnderlineDelimiter start="\(^\|[- '"({\]]\)\@<=_\ze[^ ]" end="^\@!_\([^\k_]\|$\)\@=" keepend

" Headlines
syn match orgHeadline "^\*\+\s\+.*$" keepend
hi def link orgHeadline Title

" Line Comment
syn match  orgLineComment /^\s*#\s\+.*$/ keepend
hi def link orgLineComment Comment

" Block Comment
syn region orgBlockComment matchgroup=orgBlockCommentDelimiter start="\c^\s*#+BEGIN_COMMENT" end="\c^\s*#+END_COMMENT" keepend
hi def link orgBlockComment Comment
hi def link orgBlockCommentDelimiter Comment

" Lists
syn match orgUnorderedListMarker "^\s*[-+]\s\+" keepend
hi def link orgUnorderedListMarker markdownOrderedListMarker
syn match orgOrderedListMarker "^\s*\(\d\|\a\)\+[.)]\s\+" keepend
hi def link orgOrderedListMarker markdownOrderedListMarker
"
" Verbatim
syn region orgVerbatimInline matchgroup=orgVerbatimInlineDelimiter start="\(^\|[- '"({\]]\)\@<==\ze[^ ]" end="^\@!=\([^\k=]\|$\)\@=" keepend
hi def link orgVerbatimInline markdownCodeBlock
hi def link orgVerbatimInlineDelimiter orgVerbatimInline
syn region orgVerbatimBlock matchgroup=orgVerbatimBlockDelimiter start="\c^\s*#+BEGIN_.*" end="\c^\s*#+END_.*" keepend
hi def link orgVerbatimBlock orgCode
hi def link orgVerbatimBlockDelimiter orgVerbatimBlock

syntax match  org_verbatim /^\s*>.*/
syntax match  org_code     /^\s*:.*/

let b:current_syntax = "org"

" Fenced languages {{{

syntax region org_verbatim start="^\s*#+BEGIN_.*"      end="^\s*#+END_.*"      keepend contains=org_block_delimiter
if !exists('g:org_fenced_languages')
  g:org_fenced_languages = []
endif
let s:done_include = {}
" let s:concealends = 'concealends'
let s:concealends = ''
for s:type in map(copy(g:org_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if has_key(s:done_include, matchstr(s:type,'[^.]*'))
    continue
  endif
  if s:type =~ '\.'
    let b:{matchstr(s:type,'[^.]*')}_subtype = matchstr(s:type,'\.\zs.*')
  endif
  syn case match
  exe 'syn include @orgHighlight_'.tr(s:type,'.','_').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  unlet! b:current_syntax
  let s:done_include[matchstr(s:type,'[^.]*')] = 1
endfor
unlet! s:type
unlet! s:done_include
let s:done_include = {}
for s:type in g:org_fenced_languages
  if has_key(s:done_include, matchstr(s:type,'[^.]*'))
    continue
  endif
  exe 'syn region orgHighlight_'.substitute(matchstr(s:type,'[^=]*$'),'\..*','','').' matchgroup=orgcodeDelimiter start="^\s*#+BEGIN_SRC '.s:type.'" end="^\s*#+END_SRC" keepend contains=@orgHighlight_'.tr(matchstr(s:type,'[^=]*$'),'.','_') .' '.s:concealends
  exe 'syn region orgHighlight_'.substitute(matchstr(s:type,'[^=]*$'),'\..*','','').  ' matchgroup=orgCodeDelimiter start="^\s*#+BEGIN_SRC '.s:type.'" end="^\s*#+END_SRC" keepend contains=@orgHighlight_'.tr(matchstr(s:type,'[^=]*$'),'.','_').' '.s:concealends
  let s:done_include[matchstr(s:type,'[^.]*')] = 1
endfor
unlet! s:type
unlet! s:done_include
" BEGIN_SRC

" syntax region org_code     start="^\s*#+BEGIN_SRC"     end="^\s*#+END_SRC"     keepend contains=org_block_delimiter
syntax region org_code     start="^\s*#+BEGIN_EXAMPLE" end="^\s*#+END_EXAMPLE" keepend contains=org_block_delimiter

hi def link org_code     String
hi def link org_verbatim String
hi def link orgCodeDelimiter Comment

let b:current_syntax = "org"

" }}}
" Activar spell checking en regiones de texto
syn spell toplevel

" Tex Support {{{
unlet b:current_syntax
syn include @LATEX syntax/tex.vim
" if index(g:pandoc#syntax#conceal#blacklist, 'inlinemath') == -1
    " Can't use WithConceal here because it will mess up all other conceals
    " when dollar signs are used normally. It must be skipped entirely if
    " inlinemath is blacklisted
    syn region pandocLaTeXInlineMath start=/\v\\@<!\$\S@=/ end=/\v\\@<!\$\d@!/ keepend contains=@LATEX containedin=ALL
    syn region pandocLaTeXInlineMath start=/\\\@<!\\(/ end=/\\\@<!\\)/ keepend contains=@LATEX containedin=ALL
" endif
syn match pandocEscapedDollar /\\\$/ conceal cchar=$
syn match pandocProtectedFromInlineLaTeX /\\\@<!\${.*}\(\(\s\|[[:punct:]]\)\([^$]*\|.*\(\\\$.*\)\{2}\)\n\n\|$\)\@=/ display
" contains=@LATEX
syn region pandocLaTeXMathBlock start=/\$\$/ end=/\$\$/ keepend contains=@LATEX
syn region pandocLaTeXMathBlock start=/\\\@<!\\\[/ end=/\\\@<!\\\]/ keepend contains=@LATEX
syn match pandocLaTeXCommand /\\[[:alpha:]]\+\(\({.\{-}}\)\=\(\[.\{-}\]\)\=\)*/ contains=@LATEX
syn region pandocLaTeXRegion start=/\\begin{\z(.\{-}\)}/ end=/\\end{\z1}/ keepend contains=@LATEX
" we rehighlight sectioning commands, because otherwise tex.vim captures all text until EOF or a new sectioning command
syn region pandocLaTexSection start=/\\\(part\|chapter\|\(sub\)\{,2}section\|\(sub\)\=paragraph\)\*\=\(\[.*\]\)\={/ end=/\}/ keepend
syn match pandocLaTexSectionCmd /\\\(part\|chapter\|\(sub\)\{,2}section\|\(sub\)\=paragraph\)/ contained containedin=pandocLaTexSection
syn match pandocLaTeXDelimiter /[[\]{}]/ contained containedin=pandocLaTexSection
" }}}3
"autocmd BufEnter *.org call CallSyntaxRange()
" call CallSyntaxRange()
" syntax sync clear

let b:current_syntax = "org"


" vim: ts=8 sts=2 sw=2 et
