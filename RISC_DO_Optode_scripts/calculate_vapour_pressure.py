def calculate_vapour_pressure(T):
    """
    Calculate water vapour pressure (hPa) from temperature (°C), following ... 

    ARGS: 
        T : float or array-like
            Temperature in degC (CHECK IF FROM OPTODE OR CTD)
    """
    return np.exp(52.57 - (6690.0 / (T + 273.15)) - 4.681 * np.log(T + 273.15))

