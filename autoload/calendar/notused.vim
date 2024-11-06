vim9script
g:org_cal_startday
# vim: set foldmethod=marker:
# Info: {{{
# General_info: {{{ 
# El plugin de calendario se usará en diferentes maneras, puede ser únicamente
# el mes, el mes previo y el siguiente, tanto en formato vertical como
# horizontal, y anual.
# Para el formato de cómo calcular, necesita saber el año y mes, por defecto
# se hará siempre con la información principal.
# Si es anual, se calculará el primer día de enero y si no es el primer día
# marcado en g:org_cal_startday, se pondrán espacios, se pasará por semana de
# string y se añadirá a una lista de listas. Así por cada mes de registro.
# Si es horizontal anual, se hará de 3 meses en 3 meses, similar al calc de
# terminal, si es vertical anual, se pondrán mes por mes, si es agenda calc
# horizontal, se pondrá el mes previo, luego el mes actual, y luego el
# posterior.
# Se irá rellenando acorde a lo necesario.
# - Obtener info de tipo de calendario y mes, año de calendario. 
# - Si es anual, calcular strings para todos los meses del año.
# - Si es de trimestre, obtener mes previo, mes actual y siguiente mes.
# - Obtener primer día del mes por cada mes, y número de meses, considerar si
#   es año bisiesto para el número de meses y días y aplicar acorde al
#   algoritmo de zeller.
# - Generar espacios hasta que aparezca el primer día, llenar la lista de ésa
#   semana, luego de terminada, insertar en la lista de todo el calendario
#   del mes y así sucesivamente. Llenar todos los meses a poner y termina.
# }}}
# Calculate_days_info: {{{
# Primero es revisar el mes y tipo, se obtiene el mes principal ( si es anual,
# se calcula con enero y así sucesivamente ), si es trimestral tipo agenda, se
# calcula primero el mes actual, luego el previo y luego el siguiente, si es
# bimestral, primero el actual y luego el siguiente y así sucesivamente.
#  }}}
# Fill_days_info: {{{ 
# Primero es tener qué día es el primero del mes, si es lunes, martes,
# etcétera, 
# - leer el día en que inicia el calendario (si empieza en domingo,
#   lunes o el día que sea, la variable g:org_cal_startday lo dictará y va del 1
#   al 7, si es mayor o menor al rango, se tomará por defecto el domingo), 
# - luego se verá si el número de día es distinto al domingo y se adelantará o
#   atrasará, en caso que el día sea mayor al domingo, se le sumará el número
#   del día, por ejemplo si es de domingo a sábado, irá la lista 1,2,3,4,5,6,7,
#   si es lunes irá 2,3,4,5,6,7,8 y así, sábado será el día 7 y su caso será
#   7,8,9,10,11,12,13 
# }}}
#  }}}
# Utilities {{{
def ABisiesto(vyear: number): number # {{{
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
#  }}}
# Check the type of calendar {{{
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
  endif
enddef # }}}
def StringsCalAgH(calyear: number, calmonth: number, calday: number): list<any> # Incomplete {{{
  var liststrings = []
  var listweek = []
  return liststrings
enddef # }}}
def StringsCalAgV(calyear: number, calmonth: number, calday: number): list<any> # Incomplete {{{
  var liststrings = []
  var listweek = []
  return liststrings
enddef # }}}
def StringsCalYrH(calyear: number, calmonth: number, calday: number): list<any> # Incomplete {{{
  var liststrings = []
  var listweek = []
  return liststrings
enddef # }}}
def StringsCalYrV(calyear: number, calmonth: number, calday: number): list<any> # Incomplete {{{
  var liststrings = []
  var listweek = []
  return liststrings
enddef # }}}
def StringsCalOneMonth(calyear: number, calmonth: number, calday: number): list<any> # Incomplete {{{
  var liststrings = []
  var listweek = []
  return liststrings
enddef # }}}
# }}}
def StringsCalMonth(dayspermonth: number, daystart: number, startcal: number): list<any> # {{{
  # Variable declarations {{{
  var listmonth = []
  var i = 0
  var listweek = []
  var spaceslist = []
  var numd = 1
  if !exists('g:org_cal_startday') && !exists('g:org_cal_startday')
    g:org_cal_startday = 1 # 1 for sunday, 2 for monday and so on
  endif
  if !exists('b:org_cal_startday')
    b:org_cal_startday = g:org_cal_startday
  endif
  var days_counter = b:org_cal_startday + 6
  # }}}
  # Add spaces until the very fist day starts {{{
  add(listweek, '1')
  if daystart + 6 > b:org_cal_startday
    spaceslist = repeat([' '], daystart + 6 - b:org_cal_startday )
  endif
  # }}}
  if daystart > g:org_cal_startday
    while i < 7
      if i == g:org_cal_startday
        add(listweek, '1')
        break
      else
        add(listweek, '  ')
        i += 1
      endif
    endwhile
  else
    add(listweek, '1')
  endif
  numd = 2
  while numd <= dayspermonth
    add(listweek, string(numd))
    if len(listweek) == 7
      add(listmonth, listweek)
      listweek = []
    endif
    numd += 1
  endwhile
  echo len(listmonth)
  while len(listweek) < 7
    add(listweek, '  ')
  endwhile
  add(listmonth, listweek)
  # if len(listmonth[-1]) != 7
  #   while len(listmonth[-1]) != 7
  #     add(listmonth[-1], '  ')
  #   endwhile
  # endif
  echo listmonth
  return listmonth
enddef # }}}
def CalculateMonthDays(lpyear: number, mnthnumber: number = str2nr(strftime('%m'))): list<any> # Incomplete {{{
enddef # }}}
export def PrintCalendarFull(vyear: number = str2nr(strftime('%Y')), 
    vmonth: number = str2nr(strftime('%m')), 
    vday: number = str2nr(strftime('%d'))) # {{{
  echo 'Start edit'
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
export def PrintCalendarThisMonth(): list<any> # {{{
  var thismonth = strftime('%m')
  var thisyear = strftime('%Y')
  var thisday = strftime('%d')
  var typeyear = ABisiesto(str2nr(thisyear))
enddef # }}}

call StringsCalMonth(31, 4, 22)
