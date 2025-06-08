def congruencia_zeller(dia, mes, año):
    """
    Calcula el día de la semana usando la Congruencia de Zeller.

    Args:
        dia (int): Día del mes (1-31)
        mes (int): Mes (1-12)
        año (int): Año (ej. 2023)

    Returns:
        str: Nombre del día de la semana (ej. "Lunes")
    """
    # Ajuste para enero y febrero (Zeller considera enero y febrero como meses
    # 13 y 14 del año anterior)
    if mes < 3:
        mes += 12
        año -= 1

    # Variables según la fórmula de Zeller
    K = año % 100  # Año dentro del siglo
    J = año // 100  # Siglo
    q = dia         # Día del mes

    # Cálculo según la fórmula
    h = (q + ((13 * (mes + 1)) // 5) + K + (K // 4) + (J // 4) + (5 * J)) % 7

    # Mapeo del resultado (h) al día de la semana
    dias_semana = ["Sábado", "Domingo", "Lunes", "Martes", "Miércoles",
                   "Jueves", "Viernes"]
    return dias_semana[h]


# Ejemplo de uso
dia = 9
mes = 6
año = 2025
print(f"El {dia}/{mes}/{año} es {congruencia_zeller(dia, mes, año)}")
