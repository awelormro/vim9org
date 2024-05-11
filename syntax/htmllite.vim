" vim: set fdm=marker:
" Start syntax {{{
" Archivo: html_light.vim

" Archivo: html_light.vim

" Comentarios
syntax match htmlComment "<!--.*-->" contains=@NoSpell

" Etiquetas HTML
syntax match htmlTag "<[^>/]\+>"

" Etiquetas de cierre HTML
syntax match htmlEndTag "</[^>]\+>"

" Atributos
syntax match htmlAttribute / [a-zA-Z:]\+[ ]/

" Valores de atributos
syntax match htmlAttributeValue /"[^"]*"/

" Entidades HTML
syntax match htmlEntity "&#\d\+;\|&[a-zA-Z]\+;"

" Enlaces
syntax match htmlLink "<a href=['\"].*['\"]>"

" Números
syntax match htmlNumber /\d\+/

" Cadena de texto
syntax match htmlString /".*"/

" Asignar colores
highlight def link htmlComment Comment
highlight def link htmlTag Keyword
highlight def link htmlEndTag Keyword
highlight def link htmlAttribute Identifier
highlight def link htmlAttributeValue String
highlight def link htmlEntity Special
highlight def link htmlLink Underlined
highlight def link htmlNumber Number
highlight def link htmlString String

" Asignar la sintaxis de HTML al archivo .html
" augroup filetypedetect
"   au! BufRead,BufNewFile *.html setfiletype html
" augroup END
" }}}
