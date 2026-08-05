def calculate_air_saturation(delta_p, p_vapour):
    """
    Calculate the air saturation (%), following ... 

    ARGS: 
        delta_p : float or array-like
            Partial pressure of oxygen in hPa
        p_vapour : float or array-like
            Water vapour pressure in hPa

    RETURNS:
        AirSaturation: float or array-like
            Air saturation percentage. 
    """

    NomAirPress = 1013.25 # nominal air pressure, hPa
    NomAirMix = 0.20946 # nominal oxygen content in air, hPa
    
    AirSaturation = (delta_p * 100) / ((NomAirPress - p_vapour) * NomAirMix)

    return AirSaturation