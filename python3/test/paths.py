import os
import vim
def PruebaFuncion():
    linea_especifica = vim.current.buffer[1]
    nombre_buffer = vim.current.buffer.name
    tamano_buffer = len(vim.current.buffer)
    contenido_buffer = vim.current.buffer[:]
    print(contenido_buffer[1:3])
    print(nombre_buffer)

def GenerarMappings(mapslist):
    pass
