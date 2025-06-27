" vim:set fdm=marker:
" vim:set nospell:
" vimscript part {{{
if !has('vim9script')
  finish
endif
" }}}
vim9script
# Vim9script  {{{
# 󰈔 import files {{{
import autoload "v9sc/searchers.vim" as srch
import autoload "v9sc/tags.vim" as tgs
import autoload "v9sc/parser.vim" as parse
import autoload "v9sc/searchbuffers.vim" as srchbuf
import autoload "v9sc/checkbox.vim" as chck
# }}}
#  Command creations {{{
command -buffer OrgSearchNextHeader srch.Find_next_header()
command -buffer OrgSearchPrevHeader srch.Find_prev_header()
command -buffer OrgSearchNextLink   srch.Find_next_link()
command -buffer OrgSearchPrevLink   srch.Find_prev_link()
command -buffer OrgSearchNextCite   srch.Find_next_cite()
command -buffer OrgSearchPrevCite   srch.Find_prev_cite()
command -buffer OrgAllTags          tgs.Parser_for_tags()
command -buffer OrgTestTokens       parse.Generate_tokens(getline('.'))
command -buffer OrgTestParsing      parse.Tags_parser_line(getline('.'))
command -buffer OrgGenerateTags     parse.Tag_parsing_header()
command -buffer OrgMenuTags         srchbuf.Generate_Tags_menu()
command -buffer OrgCheckBoxToggle   chck.ToggleChecklist()
command -buffer OrgTagsHeader       tgs.Org_Header_Extractor()
# }}}
# Plug mapping creations {{{
map <silent> <Plug>(OrgFindPrevCite) :OrgSearchPrevCite<CR>:echo <CR>
map <silent> <Plug>(OrgFindPrevHead) :OrgSearchPrevHeader<CR>:echo <CR>
map <silent> <Plug>(OrgFindPrevLink) :OrgSearchPrevLink<CR>:echo <CR>
map <silent> <Plug>(OrgFindNextCite) :OrgSearchNextCite<CR>:echo <CR>
map <silent> <Plug>(OrgFindNextHead) :OrgSearchNextHeader<CR>:echo <CR>
map <silent> <Plug>(OrgFindNextLink) :OrgSearchNextLink<CR>:echo <CR>

# }}}
# mapping creations {{{
nmap [[ <Plug>(OrgFindPrevHead)
nmap ]] <Plug>(OrgFindNextHead)
nmap <Leader>lp <Plug>(OrgFindPrevLink)
nmap <Leader>ln <Plug>(OrgFindNextLink)
nmap <Leader>cp <Plug>(OrgFindPrevCite)
nmap <Leader>cn <Plug>(OrgFindNextCite)
# }}}
# }}}
