def oxygen_solubility_garcia_gordon_1992(T, S = 35):
    """
    Calculate oxygen solubility C* (cm³/dm³) using Garcia & Gordon (1992).
    
    ARGS: 
        T : float or array
            Temperature in °C
        S : float
            Salinity (default = 35)

    RETURNS:
        C_star : float or array
            Oxygen solubility in cm³/dm³
    """

    # Garcia & Gordon (1992) coefficients
    A0 = 2.00856
    A1 = 3.22400
    A2 = 3.99063
    A3 = 4.80299
    A4 = 9.78188e-1
    A5 = 1.71069

    B0 = -6.24097e-3
    B1 = -6.93498e-3
    B2 = -6.90358e-3
    B3 = -4.29155e-3

    C0 = -3.11680e-7

    # Scaled temperature
    Ts = np.log((298.15 - T) / (273.15 - T))

    # Main Garcia & Gordon exponential term
    C_star = np.exp(
        A0
        + A1 * Ts
        + A2 * Ts**2
        + A3 * Ts**3
        + A4 * Ts**4
        + A5 * Ts**5
        + S * (B0 + B1 * Ts + B2 * Ts**2 + B3 * Ts**3)
        + C0 * S**2
    )

    return C_star