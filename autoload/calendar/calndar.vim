vim9script
# vim: set foldmethod=marker:
export def PrintCalendar(year: number) # {{{
  var vyear = str2nr(strftime('%Y'))
  var vmonth = str2nr(strftime('%m'))
  var vday = str2nr(strftime('%d'))
  var bisflag = 0
  if year % 100 == 0 && year % 400 != 0
    echo 'No múltiplo de 100'
    bisflag = 0
  endif
  if year % 4 == 0
    echo 'Es año bisiesto'
    bisflag = 1
  else
    echo 'No es año Bisiesto'
  endif
enddef # }}}

call PrintCalendar(1904)
call PrintCalendar(1905)
