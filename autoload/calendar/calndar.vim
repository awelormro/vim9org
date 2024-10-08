vim9script
# vim: set foldmethod=marker:
# Add as a new Branch to avoid the work into substancial files

def ABisiesto(vyear: number): number # {{{
  if vyear % 100 == 0
    if vyear % 400 != 0
      return 0
    else
      return 1
    endif
  endif
  var vflag = vyear % 4
  # echo vflag
  if vflag == 0
    # echo vyear % 4
    return 1
  else
    return 0
  endif
enddef #  }}}
def WeekDay(vyea: number, vmon: number, vday: number): number # {{{
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
  return dayofyear
enddef # }}}
export def PrintCalendarFull(year: number) # {{{
  var vyear = year
  var vmonth = str2nr(strftime('%m'))
  var vday = str2nr(strftime('%d'))
  var bisflag = ABisiesto(vyear)
  var totdays = 0
  var dayspermonth = []
  if bisflag == 1
    totdays = 366
    dayspermonth = [ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
  else
    totdays = 365
    dayspermonth = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
  endif
  var dayofyear = WeekDay(vyear, 1, 1)
  var dayofweek = "Sunday"
  var dayweekshort = "Sun"
  var daycounter = 0
  if dayofyear == 0
    dayofweek = g:org_days_of_week[6]
    dayweekshort = g:org_days_of_week_short[6]
    daycounter = 7
  elseif dayofyear == 1
    dayofweek = g:org_days_of_week[0]
    dayweekshort = g:org_days_of_week_short[0]
    daycounter = 1
  else
    daycounter = dayofyear - 1
    dayofweek = g:org_days_of_week[daycounter]
    dayweekshort = g:org_days_of_week_short[daycounter]
  endif
  var i = 0
  var j = 0
  var k = dayofyear
  echo dayofyear
  echo dayofweek
  echo dayweekshort
  var calendar_list = []
  var month_list = []
  while i <= 11
    j = 1
    month_list = []
    while j <= dayspermonth[i]
      if daycounter > 6
        daycounter = 0
      endif
      add(month_list, g:org_days_of_week[daycounter])
      daycounter += 1
      j += 1
    endwhile
    echo month_list
    add(calendar_list, month_list)
    i += 1
  endwhile
enddef # }}}
export def PrintCalendarThisMonth() # {{{
enddef # }}}
export def PrintCalendarMonth() # {{{
enddef # }}}

call PrintCalendarFull(2024)
