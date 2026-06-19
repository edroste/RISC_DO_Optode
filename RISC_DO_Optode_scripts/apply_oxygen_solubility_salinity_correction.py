def apply_oxygen_solubility_salinity_correction(S, T, Spreset=0):
    """
    Compute the salinity correction factor SCorr from Garcia & Gordon (1992), using the Benson & Krause refit.
    Also see Bittig et al. (2016). 

    ARGS: 
        S : float or array
            Actual salinity.
        T : float or array
            Temperature in °C.
        Spreset : float, optional
            Reference salinity (e.g., 0 for freshwater or 35 for preset seawater).

    RETURNS: 
        SCorr : float or array
            SCorr salinity correction factor.
    """

    # Coefficients (Garcia & Gordon 1992 – Benson & Krause refit)
    B0 = -6.24523e-3
    B1 = -7.37614e-3
    B2 = -1.03410e-2
    B3 = -8.17083e-3
    C0 = -4.88682e-7

    # Scaled temperature term Ts
    Ts = np.log((298.15 - T) / (273.15 + T))

    # SCorr computation
    SCorr = np.exp(
        (S - Spreset) * (B0 + B1*Ts + B2*(Ts**2) + B3*(Ts**3))
        + C0 * ((S**2) - (Spreset**2))
    )

    return SCorr