vim9script
# vim: set foldmethod=marker: 

# Función que crea un diario o abre el existente
export def DiaryEntry() # {{{ 
    var diary_path = expand("~/diarios/")
    var date_str = strftime("%Y-%m-%d")
    var file_name = diary_path .. date_str .. ".org"

    # Verificar si el directorio 'diarios' existe, si no, crearlo
    if !isdirectory(diary_path)
        mkdir(diary_path, "p")
    endif

    # Verificar si el archivo ya existe
    if filereadable(file_name)
        execute 'edit ' .. file_name
    else
        execute 'edit ' .. file_name
        call append(0, "# Diario: " .. date_str)
        call append(1, "")
        call append(2, "* Reflexión del día")
    endif
enddef # }}}

