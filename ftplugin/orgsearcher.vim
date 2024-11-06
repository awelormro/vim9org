vim9script

setlocal bufhidden=wipe buftype=nofile nobuflisted nocursorcolumn nocursorline nolist nospell nonumber noswapfile norelativenumber
# autocmd TextChanged,FileType orgsearcher {
#   b:currsearch = matchfuzzy(b:orgsearchtags, getline(1)[5 :])
#   var i = 2
#   execute 'delete ' .. string( i - line('$') )
#   for searchres in b:currsearch
#     setline( line('$') + 1, searchres )
#   endfor
#   }
