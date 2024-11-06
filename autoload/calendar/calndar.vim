vim9script
# vim: set foldmethod=marker:
# Add as a new Branch to avoid the work into substancial files
# Info: {{{ 
#
# }}}
# Utilities: {{{
def ABisiesto(vyear: number = str2nr(strftime('%m'))): number # {{{
  if vyear % 100 == 0
    if vyear % 400 != 0
      return 0
    else
      return 1
    endif
  endif
  var vflag = vyear % 4
  if vflag == 0
    return 1
  else
    return 0
  endif
enddef #  }}}
def WeekDay(vyea: number, vmon: number, vday: number): number # {{{
  # h es el día de la semana (0 = sábado, 1 = domingo, 2 = lunes, 3 = martes, 4 = miércoles, 5 = jueves, 6 = viernes).
  var qd = vday
  var mn = vmon
  var yr = vyea
  if mn <= 2
    mn += 12
    yr -= 1
  endif
  var kval = yr % 100
  var jval = yr / 100
  var dayofyear = (qd + ((mn + 1) * 26) / 10 + kval + (kval / 4) + jval / 4 - 2 * jval) % 7
  # echo dayofyear
  if dayofyear == 0
    return 7 # Saturday will be considered as the last day
  else
    return dayofyear
  endif
  # return dayofyear
enddef # }}}
def DaysOfMonth(mth: number, abyr: number): number # {{{
  var daysOfMonth = []
  if abyr == 1
    daysOfMonth = [ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
  else
    daysOfMonth = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
  endif
  return daysOfMonth[mth - 1]
enddef # }}}
def StringsCalendar(vdate: list<any> = [ strftime('%Y'), strftime('%m'), strftime('%d') ]): list<any> # {{{
  # Declare variables to make the calendar {{{
  var vdata = []
  var dayofmonth = 2
  var weekday = 1
  var listspaces = []
  var daysweek = []
  var listweeks = []
  # }}}
  # Variable global generations in case to make it {{{
  for elem in vdate
    if type(elem) == 1
      add(vdata, str2nr(elem))
    else
      add(vdata, elem)
    endif
  endfor
  var startday = WeekDay(str2nr(vdate[0]), str2nr(vdate[1]), 1)
  # echo startday
  var daysofmonth = DaysOfMonth(str2nr(vdate[1]), ABisiesto(str2nr(vdate[0])))
  # echo daysofmonth
  if !exists('g:org_days_of_week')
    g:org_days_of_week = [ 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday' ]
  endif
  if !exists('b:org_days_of_week')
    b:org_days_of_week = g:org_days_of_week
  endif
  if !exists('g:org_days_of_week_short')
    g:org_days_of_week_short = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ]
  endif
  if !exists('b:org_days_of_week_short')
    b:org_days_of_week_short = g:org_days_of_week_short
  endif
  if !exists('g:org_cal_months')
    g:org_cal_months = [ 'January', 'February', 'March', 'April', 'May', 
                         'June', 'July', 'August', 'September', 'October', 
                         'November', 'December' ]
  endif
  if !exists('b:org_cal_months')
    b:org_cal_months = g:org_cal_months
  endif
  if !exists('g:org_cal_months_short')
    g:org_cal_months_short = [ 'Jan', 'Feb', 'Mar', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ]
  endif
  if !exists('b:org_cal_months_short')
    b:org_cal_months_short = g:org_cal_months_short
  endif
  # }}}
  # Loop to check the very first week {{{
  if startday > 1
    daysweek = extend(repeat([' '], startday - 1), ['1'])
  else
    add( daysweek, '1' )
  endif
  while dayofmonth < daysofmonth + 1
    while len(daysweek) < 7 && dayofmonth < daysofmonth + 1
      add( daysweek, string(dayofmonth) )
      dayofmonth += 1
    endwhile
    extend(daysweek, repeat([' '], 7 - len(daysweek)))
    add( listweeks, daysweek )
    daysweek = []
  endwhile
  # echo listweeks
  # }}}
  return listweeks
enddef # }}}
def CalendarNameMonth(calmonth: number): string # {{{
  var cal_month_namme = g:org_
enddef # }}}
#  }}}
# Calendar_checker: the type of calendar {{{
def CalendarChecker(caltype:  string = 'agendah',
                    calyear:  number = str2nr(strftime('%Y')),
                    calmonth: number = str2nr(strftime('%m')),
                    calday:   number = str2nr(strftime('%d'))
    ): list<any> # {{{
  if caltype == 'agendah'
    return StringsCalAgH(calyear, calmonth, calday)
  elseif caltype == 'agendav'
    return StringsCalAgV(calyear, calmonth, calday)
  elseif caltype == 'yearh'
    return StringsCalYrH(calyear, calmonth, calday)
  elseif caltype == 'yearv'
    return StringsCalYrV(calyear, calmonth, calday)
  elseif caltype == 'monthly'
    return StringsCalOneMonth(calyear, calmonth, calday)
  else
    return StringsCalOneMonth(calyear, calmonth, calday)
  endif
enddef # }}}
def SyntaxIncluded(langs: list<any> = [ 'html', 'css', 'python', 'javascript', 'tex' ]) # {{{
  var capslang = ''
  var sniplang = ''
  for vlang in langs
    capslang = toupper(vlang)
    sniplang = vlang .. 
    exe 'syntax include @' .. 'capslang syntax/' .. lang .. '.vim'
    exe 'syn region ' .. 'snip matchgroup=Snip' .. ' start="#+BEGIN_SRC ' .. lang .. '" end="#+END_SRC=' .. lang .. '" contains=' .. 
    exe 'hi link pysnip SpecialComment'
    syntax on
  endfor
enddef
# }}}
# syntax include @PYTHON syntax/python.vim
# syn region pysnip matchgroup=Snip start="@begin=python" end="@end=python" contains=@PYTHON
# hi link pysnip SpecialComment
# syntax on
# @begin=python
# for i in 3:
#   print('holi')
# @end=python
# }}}
# Calendar_types: {{{
def StringsCalOneMonth(calyear: number, calmonth: number, calday: number): list<any> # Complete {{{
  # Variable declarations {{{
  var listdata = [ string(calyear), string(calmonth), string(calday) ]
  var liststrings = StringsCalendar( listdata )
  var listweek = []
  var finalcal = [ ' ' .. join( g:org_days_of_week_short, ' ' ) ]
  var auxstring = ''
  # }}}
  # Loop to add to the variables to the string {{{
  for week in liststrings
    listweek = []
    auxstring = ''
    for day in week
      if strlen(day) == 1
        add(listweek, ' ' .. day)
      else
        add(listweek, day )
      endif
    endfor
    for day in listweek
      auxstring = auxstring .. '  ' .. day
    endfor
    # echo auxstring
    add( finalcal, auxstring )
  endfor
  var monthname = b:org_cal_months[calmonth - 1]
  var titlelen = strlen(finalcal[0])
  # echo monthname
  var concatparts = monthname .. ' ' .. string(calyear)
  var addspacestitle = strlen(finalcal[0]) - strlen(concatparts)
  if addspacestitle / 2 * 2 == addspacestitle
    concatparts = repeat(' ', addspacestitle / 2) .. concatparts .. repeat(' ', addspacestitle / 2)
  else
    concatparts =  repeat(' ', addspacestitle / 2) .. concatparts .. repeat(' ', addspacestitle / 2) .. ' '
  endif
  finalcal = extend([concatparts], finalcal)
  # echo concatparts
  # }}}
  # Check elements in the list {{{
  # for week in finalcal
  #   echo week
  # endfor
  # }}}
  return finalcal
enddef # }}}
def StringsCalAgH(calyear: number, calmonth: number, calday: number): list<any> # complete {{{
  var liststrings = []
  var prevmonth = calmonth - 1
  var nextmonth = calmonth + 1
  var prevyear = calyear 
  var nextyear = calyear
  if prevmonth == 0
    prevmonth = 12
    prevyear = prevyear - 1
  endif
  if nextmonth == 13
    nextmonth = 1
    nextyear = calyear + 1
  endif
  var prevmonthdays = StringsCalOneMonth( prevyear, prevmonth, 1 )
  var nextmonthdays = StringsCalOneMonth( nextyear, nextmonth, 1 )
  var currmonthdays = StringsCalOneMonth( calyear, calmonth, 1 )
  var lenpmdays = len(prevmonthdays)
  var lennmdays = len(nextmonthdays)
  var lencmdays = len(currmonthdays)
  var maxlencal = max( [lenpmdays, lennmdays, lencmdays] )
  while len( prevmonthdays ) < maxlencal
    add( prevmonthdays, repeat(' ', len(prevmonthdays[0])) )
  endwhile
  while len( nextmonthdays ) < maxlencal
    add( nextmonthdays, repeat(' ', len(nextmonthdays[0])) )
  endwhile
  while len( currmonthdays ) < maxlencal
    add( currmonthdays, repeat(' ', len(currmonthdays[0])) )
  endwhile
  var i = 0
  while i < len(currmonthdays)
    add(liststrings, prevmonthdays[i] .. ' ' .. currmonthdays[i] .. ' ' .. nextmonthdays[i] )
    i += 1
  endwhile
  return liststrings
enddef # }}}
def StringsCalAgV(calyear: number, calmonth: number, calday: number): list<any> # complete {{{
  var prevmonth = calmonth - 1
  var nextmonth = calmonth + 1
  var prevyear = calyear 
  var nextyear = calyear
  if prevmonth == 0
    prevmonth = 12
    prevyear = prevyear - 1
  endif
  if nextmonth == 13
    nextmonth = 1
    nextyear = calyear + 1
  endif
  var liststrings = []
  liststrings = extend(liststrings, StringsCalOneMonth(prevyear, prevmonth, 1))
  liststrings = extend(liststrings, StringsCalOneMonth(calyear, calmonth, 1))
  liststrings = extend(liststrings, StringsCalOneMonth(nextyear, nextmonth, 1))
  return liststrings
enddef # }}}
def StringsCalYrH(calyear: number, calmonth: number, calday: number): list<any> # complete {{{
  var liststrings = []
  var i = 1
  while i < 13
    extend(liststrings, StringsCalAgH(calyear, i + 1, 1))
    i += 3
  endwhile
  # echo liststrings
  return liststrings
enddef # }}}
def StringsCalYrV(calyear: number, calmonth: number, calday: number): list<any> # complete {{{
  var i = 1
  var liststrings = []
  var listweek = []
  while i < 13
    liststrings = extend(liststrings, StringsCalAgV(calyear, i + 1, 1))
    i += 3
  endwhile
  return liststrings
enddef # }}}
#
var caltypes =  CalendarChecker('yearv', 2024, 12, 22 )
for week in caltypes
  echo week
endfor
