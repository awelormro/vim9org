" vim: set fdm=marker:
"
" Support org authoring markup as closely as possible
" (we're adding two markdown-like variants for =code= and blockquotes)
" -----------------------------------------------------------------------------
"
" Do we use aggresive conceal?
if exists("b:current_syntax")
  finish
endif
let b:current_syntax='org'
if !exists('main_syntax')
  let main_syntax = 'org'
endif
if exists("b:org_aggressive_conceal")
    let s:conceal_aggressively=b:org_aggressive_conceal
elseif exists("g:org_aggressive_conceal")
    let s:conceal_aggressively=g:org_aggressive_conceal
else
    let s:conceal_aggressively=0
endif

" Inline markup {{{1
" *bold*, /italic/, _underline_, +strike-through+, =code=, ~verbatim~
" Note:
" - /italic/ is rendered as reverse in most terms (works fine in gVim, though)
" - the non-standard `code' markup is also supported
" - =code= and ~verbatim~ are also supported as block-level markup, see below.
" Ref: http://orgmode.org/manual/Emphasis-and-monospace.html
"syntax match org_bold /\*[^ ]*\*/

" FIXME: Always make org_bold syntax define before org_heading syntax
"        to make sure that org_heading syntax got higher priority(help :syn-priority) than org_bold.
"        If there is any other good solution, please help fix it.
"  \\\\*sinuate*
if (s:conceal_aggressively == 1)
  syntax region org_bold      matchgroup=org_border_bold start="[^ \\]\zs\*\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs\*\|\(^\|[^\\]\)\@<=\*\S\@="     end="[^ \\]\zs\*\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs\*\|[^\\]\zs\*\S\@="  concealends oneline
  syntax region org_italic    matchgroup=org_border_ital start="[^ \\]\zs\/\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs\/\|\(^\|[^\\]\)\@<=\/\S\@="     end="[^ \\]\zs\/\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs\/\|[^\\]\zs\/\S\@="  concealends oneline
  syntax region org_underline matchgroup=org_border_undl start="[^ \\]\zs_\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs_\|\(^\|[^\\]\)\@<=_\S\@="        end="[^ \\]\zs_\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs_\|[^\\]\zs_\S\@="     concealends oneline
  syntax region org_code      matchgroup=org_border_code start="[^ \\]\zs=\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs=\|\(^\|[^\\]\)\@<==\S\@="        end="[^ \\]\zs=\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs=\|[^\\]\zs=\S\@="     concealends oneline
  syntax region org_code      matchgroup=org_border_code start="[^ \\]\zs`\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs`\|\(^\|[^\\]\)\@<=`\S\@="        end="[^ \\]\zs'\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs'\|[^\\]\zs'\S\@="     concealends oneline
  syntax region org_verbatim  matchgroup=org_border_verb start="[^ \\]\zs\~\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs\~\|\(^\|[^\\]\)\@<=\~\S\@="     end="[^ \\]\zs\~\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs\~\|[^\\]\zs\~\S\@="  concealends oneline
  syntax region org_strikethrough  matchgroup=org_border_strike start="[^ \\]\zs+\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs+\|\(^\|[^\\]\)\@<=+\S\@="     end="[^ \\]\zs+\|\(\(^\|[^\\]\)\zs\(\\\\\)\+\)\zs+\|[^\\]\zs+\S\@="  concealends oneline
else
  syntax region org_bold      start="\S\zs\*\|\*\S\@="     end="\S\zs\*\|\*\S\@="  keepend oneline
  syntax region org_italic    start="\S\zs\/\|\/\S\@="     end="\S\zs\/\|\/\S\@="  keepend oneline
  syntax region org_underline start="\S\zs_\|_\S\@="       end="\S\zs_\|_\S\@="    keepend oneline
  syntax region org_code      start="\S\zs=\|=\S\@="       end="\S\zs=\|=\S\@="    keepend oneline
  syntax region org_code      start="\S\zs`\|`\S\@="       end="\S\zs'\|'\S\@="    keepend oneline
  syntax region org_verbatim  start="\S\zs\~\|\~\S\@="     end="\S\zs\~\|\~\S\@="  keepend oneline
  syntax region org_strikethrough  start="\S\zs+\|+\S\@="     end="\S\zs+\|+\S\@="  keepend oneline
endif

hi def org_bold      term=bold      cterm=bold      gui=bold
hi def org_italic    term=italic    cterm=italic    gui=italic
hi def org_underline term=underline cterm=underline gui=underline
hi def org_strikethrough term=strikethrough cterm=strikethrough gui=strikethrough

if (s:conceal_aggressively == 1)
  hi link org_border_bold org_bold
  hi link org_border_ital org_italic
  hi link org_border_undl org_underline
endif

" Headings: {{{1
" Load Settings: {{{2
if !exists('g:org_heading_highlight_colors')
	let g:org_heading_highlight_colors = ['Boolean', 'Constant', 'Identifier', 'Statement', 'PreProc', 'Type', 'Special']
endif

if !exists('g:org_heading_highlight_levels')
	let g:org_heading_highlight_levels = len(g:org_heading_highlight_colors)
endif

if !exists('g:org_heading_shade_leading_stars')
	let g:org_heading_shade_leading_stars = 1
endif

" Enable Syntax HL: {{{2
unlet! s:i s:j s:contains
let s:i = 1
let s:j = len(g:org_heading_highlight_colors)
let s:contains = ' contains=org_timestamp,org_timestamp_inactive,org_subtask_percent,org_subtask_number,org_subtask_percent_100,org_subtask_number_all,org_list_checkbox,org_bold,org_italic,org_underline,org_code,org_verbatim'
if g:org_heading_shade_leading_stars == 1
	let s:contains = s:contains . ',org_shade_stars'
	syntax match org_shade_stars /^\*\{2,\}/me=e-1 contained
	hi def link org_shade_stars Ignore
else
	hi clear org_shade_stars
endif

while s:i <= g:org_heading_highlight_levels
	exec 'syntax match org_heading' . s:i . ' /^\*\{' . s:i . '\}\s.*/' . s:contains
	exec 'hi def link org_heading' . s:i . ' ' . g:org_heading_highlight_colors[(s:i - 1) % s:j]
	let s:i += 1
endwhile
unlet! s:i s:j s:contains

" Todo Keywords: {{{1
" Load Settings: {{{2
if !exists('g:org_todo_keywords')
	let g:org_todo_keywords = ['TODO', 'DOING', 'DONE']
endif

if !exists('g:org_todo_keyword_faces')
	let g:org_todo_keyword_faces = []
endif

" Enable Syntax HL: {{{2
let s:todo_headings = ''
let s:i = 1
while s:i <= g:org_heading_highlight_levels
	if s:todo_headings == ''
		let s:todo_headings = 'containedin=org_heading' . s:i
	else
		let s:todo_headings = s:todo_headings . ',org_heading' . s:i
	endif
	let s:i += 1
endwhile
unlet! s:i

if !exists('g:loaded_org_syntax')
	let g:loaded_org_syntax = 1

	function! OrgExtendHighlightingGroup(base_group, new_group, settings)
		let l:base_hi = ''
		redir => l:base_hi
		silent execute 'highlight ' . a:base_group
		redir END
		let l:group_hi = substitute(split(l:base_hi, '\n')[0], '^' . a:base_group . '\s\+xxx', '', '')
		execute 'highlight ' . a:new_group . l:group_hi . ' ' . a:settings
	endfunction

	function! OrgInterpretFaces(faces)
		let l:res_faces = ''
		if type(a:faces) == 3
			let l:style = []
			for l:f in a:faces
				let l:_f = [l:f]
				if type(l:f) == 3
					let l:_f = l:f
				endif
				for l:g in l:_f
					if type(l:g) == 1 && l:g =~ '^:'
						if l:g !~ '[\t ]'
							continue
						endif
						let l:k_v = split(l:g)
						if l:k_v[0] == ':foreground'
							let l:gui_color = ''
							let l:found_gui_color = 0
							for l:color in split(l:k_v[1], ',')
								if l:color =~ '^#'
									let l:found_gui_color = 1
									let l:res_faces = l:res_faces . ' guifg=' . l:color
								elseif l:color != ''
									let l:gui_color = l:color
									let l:res_faces = l:res_faces . ' ctermfg=' . l:color
								endif
							endfor
							if ! l:found_gui_color && l:gui_color != ''
								let l:res_faces = l:res_faces . ' guifg=' . l:gui_color
							endif
						elseif l:k_v[0] == ':background'
							let l:gui_color = ''
							let l:found_gui_color = 0
							for l:color in split(l:k_v[1], ',')
								if l:color =~ '^#'
									let l:found_gui_color = 1
									let l:res_faces = l:res_faces . ' guibg=' . l:color
								elseif l:color != ''
									let l:gui_color = l:color
									let l:res_faces = l:res_faces . ' ctermbg=' . l:color
								endif
							endfor
							if ! l:found_gui_color && l:gui_color != ''
								let l:res_faces = l:res_faces . ' guibg=' . l:gui_color
							endif
						elseif l:k_v[0] == ':weight' || l:k_v[0] == ':slant' || l:k_v[0] == ':decoration'
							if index(l:style, l:k_v[1]) == -1
								call add(l:style, l:k_v[1])
							endif
						endif
					elseif type(l:g) == 1
						" TODO emacs interprets the color and automatically determines
						" whether it should be set as foreground or background color
						let l:res_faces = l:res_faces . ' ctermfg=' . l:k_v[1] . ' guifg=' . l:k_v[1]
					endif
				endfor
			endfor
			let l:s = ''
			for l:i in l:style
				if l:s == ''
					let l:s = l:i
				else
					let l:s = l:s . ','. l:i
				endif
			endfor
			if l:s != ''
				let l:res_faces = l:res_faces . ' term=' . l:s . ' cterm=' . l:s . ' gui=' . l:s
			endif
		elseif type(a:faces) == 1
			" TODO emacs interprets the color and automatically determines
			" whether it should be set as foreground or background color
			let l:res_faces = l:res_faces . ' ctermfg=' . a:faces . ' guifg=' . a:faces
		endif
		return l:res_faces
	endfunction

	function! s:ReadTodoKeywords(keywords, todo_headings)
		let l:default_group = 'Todo'
		for l:i in a:keywords
			if type(l:i) == 3
				call s:ReadTodoKeywords(l:i, a:todo_headings)
				continue
			endif
			if l:i == '|'
				let l:default_group = 'Question'
				continue
			endif
			" strip access key
			let l:_i = substitute(l:i, "\(.*$", "", "")
			let l:safename = substitute(l:_i, "\\W", "\\=('u' . char2nr(submatch(0)))", "g")

			let l:group = l:default_group
			for l:j in g:org_todo_keyword_faces
				if l:j[0] == l:_i
					let l:group = 'org_todo_keyword_face_' . l:safename
					call OrgExtendHighlightingGroup(l:default_group, l:group, OrgInterpretFaces(l:j[1]))
					break
				endif
			endfor
			silent! exec 'syntax match org_todo_keyword_' . l:safename . ' /\*\{1,\}\s\{1,\}\zs' . l:_i .'\(\s\|$\)/ ' . a:todo_headings . ' contains=@NoSpell'
			silent! exec 'hi def link org_todo_keyword_' . l:safename . ' ' . l:group
		endfor
	endfunction
endif

call s:ReadTodoKeywords(g:org_todo_keywords, s:todo_headings)
unlet! s:todo_headings

" Timestamps: {{{1
"<2003-09-16 Tue>
"<2003-09-16 Sáb>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \k\k\k>\)/
"<2003-09-16 Tue 12:00>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \k\k\k \d\d:\d\d>\)/
"<2003-09-16 Tue 12:00-12:30>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \k\k\k \d\d:\d\d-\d\d:\d\d>\)/

"<2003-09-16 Tue>--<2003-09-16 Tue>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \k\k\k>--<\d\d\d\d-\d\d-\d\d \k\k\k>\)/
"<2003-09-16 Tue 12:00>--<2003-09-16 Tue 12:00>
syn match org_timestamp /\(<\d\d\d\d-\d\d-\d\d \k\k\k \d\d:\d\d>--<\d\d\d\d-\d\d-\d\d \k\k\k \d\d:\d\d>\)/

syn match org_timestamp /\(<%%(diary-float.\+>\)/

"[2003-09-16 Tue]
syn match org_timestamp_inactive /\(\[\d\d\d\d-\d\d-\d\d \k\k\k\]\)/
"[2003-09-16 Tue 12:00]
syn match org_timestamp_inactive /\(\[\d\d\d\d-\d\d-\d\d \k\k\k \d\d:\d\d\]\)/

"[2003-09-16 Tue]--[2003-09-16 Tue]
syn match org_timestamp_inactive /\(\[\d\d\d\d-\d\d-\d\d \k\k\k\]--\[\d\d\d\d-\d\d-\d\d \k\k\k\]\)/
"[2003-09-16 Tue 12:00]--[2003-09-16 Tue 12:00]
syn match org_timestamp_inactive /\(\[\d\d\d\d-\d\d-\d\d \k\k\k \d\d:\d\d\]--\[\d\d\d\d-\d\d-\d\d \k\k\k \d\d:\d\d\]\)/

syn match org_timestamp_inactive /\(\[%%(diary-float.\+\]\)/

hi def link org_timestamp PreProc
hi def link org_timestamp_inactive Comment

" Deadline And Schedule: {{{1
syn match org_deadline_scheduled /^\s*\(DEADLINE\|SCHEDULED\):/
hi def link org_deadline_scheduled PreProc

" LaTeX syntax auxiliar {{{1

" syn match texDelimiter		"&"
" syn match texDelimiter		"\\\\"
" syn match texDelimiter    "\\cite"
" hi def link texDelimiter type

" syn match  texBeginEnd		"\\begin\>\|\\end\>" nextgroup=texBeginEndName
" syn region texBeginEndName		matchgroup=texDelimiter	start="{"		end="}"	contained	nextgroup=texBeginEndModifier	contains=texComment
" syn region texBeginEndModifier	matchgroup=texDelimiter	start="\["		end="]"	contained	contains=texComment,@texMathZones,@NoSpell


" Entorno de ecuaciones LaTeX con $$ delimitadores
" syntax region orgLatexEquation start="\\v\%([^\\]\|^\)\@<=\$\$" end="\\v\%([^\\]\|^\)\@=\$\$"

" Entorno de ecuaciones LaTeX con $ delimitadores
" syntax region orgLatexInlineEquation start="\\v\%([^\\]\|^\)\@<=\$" end="\\v\%([^\\]\|^\)\@=\$"

" syn match texStatement	"\\[a-zA-Z@]\+"
" hi def link texStatement type
" }}}
" Tables: {{{1
syn match org_table /^\s*|.*/ contains=org_timestamp,org_timestamp_inactive,hyperlink,org_table_separator,org_table_horizontal_line
syn match org_table_separator /\(^\s*|[-+]\+|\?\||\)/ contained
hi def link org_table_separator Type

" Hyperlinks: {{{1
syntax match hyperlink	"\[\{2}[^][]*\(\]\[[^][]*\)\?\]\{2}" contains=hyperlinkBracketsLeft,hyperlinkURL,hyperlinkBracketsRight containedin=ALL
if (s:conceal_aggressively == 1)
    syntax match hyperlinkBracketsLeft	contained "\[\{2}#\?"     conceal
else
    syntax match hyperlinkBracketsLeft	contained "\[\{2}"     conceal
endif
syntax match hyperlinkURL				    contained "[^][]*\]\[" conceal
syntax match hyperlinkBracketsRight	contained "\]\{2}"     conceal
hi def link hyperlink Underlined

" Comments: {{{1
syntax match org_comment /^#.*/
hi def link org_comment Comment

" References: {{{1
syntax match reference '\\ref{.*}' transparent contains=referenceStart,referenceEnd
syntax match referenceStart '\\ref{*' contained conceal cchar=[
syntax match referenceEnd '\(\\ref{\w\+\)\@<=\zs}' contained conceal cchar=]
" Citations {{{1
syntax match citing '\[cite.*:.*\]' containedin=ALL
hi def link citing Boolean
" Bullet Lists: {{{1
" Ordered Lists:
" 1. list item
" 1) list item
" a. list item
" a) list item
syn match org_list_ordered "^\s*\(\a\|\d\+\)[.)]\(\s\|$\)" nextgroup=org_list_item
hi def link org_list_ordered Identifier

" Unordered Lists:
" - list item
" * list item
" + list item
" + and - don't need a whitespace prefix
syn match org_list_unordered "^\(\s*[-+]\|\s\+\*\)\(\s\|$\)" nextgroup=org_list_item
hi def link org_list_unordered Identifier

" Definition Lists:
" - Term :: expl.
" 1) Term :: expl.
syntax match org_list_def /.*\s\+::/ contained
hi def link org_list_def PreProc

syntax match org_list_item /.*$/ contained contains=org_subtask_percent,org_subtask_number,org_subtask_percent_100,org_subtask_number_all,org_list_checkbox,org_bold,org_italic,org_underline,org_code,org_verbatim,org_timestamp,org_timestamp_inactive,org_list_def,
" texDelimiter,orgLatexEquation,orgLatexInlineEquation,texStatement
syntax match org_list_checkbox /\[[ X-]]/ contained
hi def link org_list_bullet Identifier
hi def link org_list_checkbox     PreProc

" Block Delimiters: {{{1
syntax case ignore
syntax match  org_block_delimiter /^#+BEGIN_.*/
syntax match  org_block_delimiter /^#+END_.*/
syntax match  org_key_identifier  /^#+[^ ]*:/
syntax match  org_title           /^#+TITLE:.*/  contains=org_key_identifier
hi def link org_block_delimiter Comment
hi def link org_key_identifier  Comment
hi def link org_title           Title

" Block Markup: {{{1
" we consider all BEGIN/END sections as 'verbatim' blocks (inc. 'quote', 'verse', 'center')
" except 'example' and 'src' which are treated as 'code' blocks.
" Note: the non-standard '>' prefix is supported for quotation lines.
" Note: the '^:.*" rule must be defined before the ':PROPERTIES:' one below.
" TODO: http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
syntax match  org_verbatim /^\s*>.*/
syntax match  org_code     /^\s*:.*/

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
syn spell toplevel
" BEGIN_SRC

" syntax region org_code     start="^\s*#+BEGIN_SRC"     end="^\s*#+END_SRC"     keepend contains=org_block_delimiter
syntax region org_code     start="^\s*#+BEGIN_EXAMPLE" end="^\s*#+END_EXAMPLE" keepend contains=org_block_delimiter

hi def link org_code     String
hi def link org_verbatim String
hi def link orgCodeDelimiter Comment
if (s:conceal_aggressively==1)
    hi link org_border_code     org_code
    hi link org_border_verb     org_verbatim
endif

" Properties: {{{1
syn region Error matchgroup=org_properties_delimiter start=/^\s*:PROPERTIES:\s*$/ end=/^\s*:END:\s*$/ contains=org_property keepend
syn match org_property /^\s*:[^\t :]\+:\s\+[^\t ]/ contained contains=org_property_value
syn match org_property_value /:\s\zs.*/ contained
hi def link org_properties_delimiter PreProc
hi def link org_property             Statement
hi def link org_property_value       Constant
" Break down subtasks
syntax match org_subtask_number /\[\d*\/\d*]/ contained
syntax match org_subtask_percent /\[\d*%\]/ contained
syntax match org_subtask_number_all /\[\(\d\+\)\/\1\]/ contained
syntax match org_subtask_percent_100 /\[100%\]/ contained

hi def link org_subtask_number String
hi def link org_subtask_percent String
hi def link org_subtask_percent_100 Identifier
hi def link org_subtask_number_all Identifier

" Plugin SyntaxRange: {{{1
" This only works if you have SyntaxRange installed:
" https://github.com/vim-scripts/SyntaxRange
fun CallSyntaxRange()

  if exists('g:loaded_SyntaxRange')
    unlet b:current_syntax
    call SyntaxRange#Include('#+BEGIN_SRC html', '#+END_SRC', 'htmllite', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC vim', '#+END_SRC', 'vim', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC python', '#+END_SRC', 'python', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC c', '#+END_SRC', 'c', 'comment containedin=ALL')
    " cpp must be below c, otherwise you get c syntax hl for cpp files
    call SyntaxRange#Include('#+BEGIN_SRC cpp', '#+END_SRC', 'cpp', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC haskell', '#+END_SRC', 'haskell', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC lua', '#+END_SRC', 'lua', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC css', '#+END_SRC', 'css', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC java', '#+END_SRC', 'java', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC javascript', '#+END_SRC', 'javascript', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC bash', '#+END_SRC', 'bash', 'comment containedin=ALL')
    call SyntaxRange#Include('#+BEGIN_SRC graphviz', '#+END_SRC', 'dot', 'comment containedin=ALL')
  let b:current_syntax = "org"
  endif
endf

let b:current_syntax = "org"
" LaTeX: {{{1
" Set embedded LaTex (pandoc extension) highlighting
" Unset current_syntax so the 2nd include will work
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
if main_syntax ==# 'org'
  unlet main_syntax
endif

syntax sync minlines=200
syntax sync maxlines=500
" vim:set sw=2:
