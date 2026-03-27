" vim:set fdm=marker:
" vim:set nospell:
" Legacy strings {{{
if !has('vim9script')
  finish
endif
" }}}
vim9script
import autoload "v9sc/parser.vim" as parse
export def Generate_Tags_menu() # {{{
  # Read header and obtain the variables
  var line_title_pos = search('^\*', 'bnW')
  if line_title_pos < 1
    return
  endif
  var parse_news = parse.Tag_parsing_header()
  # Generate tags
  var tags_to_show = b:org_tags 
  var show_tags = []
  var parts = []
  var excludant_lists = []
  var excludant_currlist = []
  var i = 0
  var len_tags = len(tags_to_show)
  while i < len_tags
    if tags_to_show['kind'] == 'main_hierarchy'
    endif
    i += 1
  endwhile
  # With the local header content, split and obtain the tags
  var tags_in_line = split(trim(getline(line_title_pos)))
  var splitted_tags = []
  if tags_in_line[len(tags_in_line) - 1] =~ '^:*:$'
    splitted_tags = split(tags_in_line[-1])
    echo splitted_tags
  endif
  # check if there are hierarchy tags preceded or after
  # Check if there are excludant tags, deletes all the excludant but the first
  # Generate the list of al tags
  # Open a new window and put line1: Aviable tags: list of comma separated
  # tags
  # line2: Tags: 
  # Rest of file: all the tags aviable
  # Create a function to reload all tags
  # Generate autocommands
  for tag in  tags_to_show
    if len(tag["name"]) > 0
      echo tag
    endif
  endfor

enddef # }}}
export def BufferAuxMenu(options: list<any>, )
enddef
# perro
