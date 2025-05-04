" vim:set fdm=marker:
" vim:set nospell:
" vimscript part {{{
if !has('vim9script')
  finish
endif
" }}}
vim9script
# Vim9script  {{{
# import files {{{
import autoload "v9sc/searchers.vim" as srch
import autoload "v9sc/tags.vim" as tgs
# }}}
# Command creations {{{
command -buffer OrgSearchNextHeader srch.Find_next_header()
command -buffer OrgSearchPrevHeader srch.Find_prev_header()
command -buffer OrgSearchNextLink   srch.Find_next_link()
command -buffer OrgSearchPrevLink   srch.Find_prev_link()
command -buffer OrgSearchNextCite   srch.Find_next_cite()
command -buffer OrgSearchPrevCite   srch.Find_prev_cite()
command -buffer OrgAllTags          tgs.Parser_for_tags()

# }}}
# Plug mapping creations {{{
map <Plug>(OrgFindPrevCite) :OrgSearchPrevCite<CR>:echo <CR>
map <Plug>(OrgFindPrevHead) :OrgSearchPrevHeader<CR>:echo <CR>
map <Plug>(OrgFindPrevLink) :OrgSearchPrevLink<CR>:echo <CR>
map <Plug>(OrgFindNextCite) :OrgSearchNextCite<CR>:echo <CR>
map <Plug>(OrgFindNextHead) :OrgSearchNextHeader<CR>:echo <CR>
map <Plug>(OrgFindNextLink) :OrgSearchNextLink<CR>:echo <CR>

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
