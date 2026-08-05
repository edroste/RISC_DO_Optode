"""
oxygen_conversions.py


A collection of oxygen conversion functions translated from MATLAB routines
based on SCOR WG 142 recommendations (Bittig et al., 2016).


Functions included:
- o2c_to_o2p: convert molar O2 concentration (µmol L‑1) to O2 partial pressure (mbar). 
- o2c_to_o2s: convert molar O2 concentration (µmol L‑1) to O2 saturation (%).
- o2p_to_o2c: convert O2 partial pressure (mbar) to O2 concentration (µmol L‑1).
- o2p_to_o2s: convert O2 partial pressure (mbar) to O2 saturation (%).
- o2s_to_o2c: convert O2 saturation (%) to molar O2 concentration (µmol L‑1).
- o2s_to_o2p: convert O2 saturation (%) to O2 partial pressure (mbar).


Notes:
- Temperature in °C
- Salinity in PSS‑78
- Pressure in dbar


Author: 
Date: 10-12-2025
"""


import numpy as np


def o2c_to_o2p(O2conc, T, S, P=0):
    """
    Convert molar oxygen concentration (micro-mole L-1) to oxygen partial pressure (mbar).
    According to recommendations by SCOR WG 142 "Quality Control Procedures for Oxygen and Other Biogeochemical Sensors on Floats and Gliders"

    ARGS :
        O2conc : float or array
            Oxygen concentration in µmol/L
        T : float or array
            Temperature in °C
        S : float or array
            Salinity (PSS-78)
        P : float or array, optional
            Hydrostatic pressure in dbar (default = 0)

    RETURNS : 
        pO2 : float or array
            Oxygen partial pressure in mbar
            
    """

    O2conc = np.asarray(O2conc)
    T = np.asarray(T)
    S = np.asarray(S)
    P = np.asarray(P)

    # mole fraction of O2 in dry air
    xO2 = 0.20946

    # saturated water vapor pressure in mbar
    pH2Osat = 1013.25 * np.exp(
        24.4543
        - 67.4509 * (100 / (T + 273.15))
        - 4.8489 * np.log((T + 273.15) / 100)
        - 0.000544 * S
    )

    # scaled temperature for use in TCorr and SCorr
    sca_T = np.log((298.15 - T) / (273.15 + T))

    # temperature correction part from Garcia and Gordon (1992), Benson and Krause (1984) refit mL(STP) L-1; and conversion from mL(STP) L-1 to umol L-1
    TCorr = 44.6596 * np.exp(
        2.00907
        + 3.22014 * sca_T
        + 4.05010 * sca_T**2
        + 4.94457 * sca_T**3
        - 2.56847e-1 * sca_T**4
        + 3.88767 * sca_T**5
    )

    # salinity correction part from Garcia and Gordon (1992), Benson and Krause (1984) refit ml(STP) L-1
    Scorr = np.exp(
        S * (
            -6.24523e-3
            - 7.37614e-3 * sca_T
            - 1.03410e-2 * sca_T**2
            - 8.17083e-3 * sca_T**3
        )
        - 4.88682e-7 * S**2
    )

    # constants
    Vm = 0.317   # molar volume of O2 in m3 mol-1 Pa dbar-1 (Enns et al. 1965) 
    R  = 8.314   # universal gas constant in J mol-1 K-1

    # calculate partial pressure
    pO2 = (
        O2conc
        * (xO2 * (1013.25 - pH2Osat)) 
        / (TCorr * Scorr)
        * np.exp(Vm * P / (R * (T + 273.15)))
    )

    return pO2


def o2c_to_o2s(O2conc, T, S, P=0, p_atm=1013.25):
    """
    Convert molar oxygen concentration (micro-mole L-1) to oxygen saturation (%).
    According to recommendations by SCOR WG 142 "Quality Control Procedures for Oxygen and Other Biogeochemical Sensors on Floats and Gliders"
    
    ARGS : 
        O2conc : float or array
            Oxygen concentration in µmol/L
        T : float or array
            Temperature in °C
        S : float or array
            Salinity (PSS-78)
        P : float or array, optional
            Hydrostatic pressure in dbar (default = 0)
        p_atm : float or array, optional
            Atmospheric pressure in mbar (default = 1013.25)

    RETURNS : 
        O2sat : float or array
            Oxygen saturation in %

    """

    O2conc = np.asarray(O2conc)
    T = np.asarray(T)
    S = np.asarray(S)
    P = np.asarray(P)
    p_atm = np.asarray(p_atm)

    # saturated water vapor in mbar
    pH2Osat = 1013.25 * np.exp(
        24.4543
        - 67.4509 * (100 / (T + 273.15))
        - 4.8489 * np.log((T + 273.15) / 100)
        - 0.000544 * S
    )

    # scaled temperature for use in TCorr and SCorr
    sca_T = np.log((298.15 - T) / (273.15 + T))

    # temperature correction part from Garcia and Gordon (1992), Benson and Krause (1984) refit mL(STP) L-1; and conversion from mL(STP) L-1 to umol L-1
    TCorr = 44.6596 * np.exp(
        2.00907
        + 3.22014 * sca_T
        + 4.05010 * sca_T**2
        + 4.94457 * sca_T**3
        - 2.56847e-1 * sca_T**4
        + 3.88767 * sca_T**5
    )

    # salinity correction part from Garcia and Gordon (1992), Benson and Krause (1984) refit ml(STP) L-1
    Scorr = np.exp(
        S * (
            -6.24523e-3
            - 7.37614e-3 * sca_T
            - 1.03410e-2 * sca_T**2
            - 8.17083e-3 * sca_T**3
        )
        - 4.88682e-7 * S**2
    )

    # constants
    Vm = 0.317   # molar volume of O2 in m3 mol-1 Pa dbar-1 (Enns et al. 1965)
    R  = 8.314   # niversal gas constant in J mol-1 K-1

    # Calculate oxygen saturation
    O2sat = (
        O2conc * 100
        / (TCorr * Scorr)
        / (p_atm - pH2Osat)
        * (1013.25 - pH2Osat)
        * np.exp(Vm * P / (R * (T + 273.15)))
    )

    return O2sat

def o2p_to_o2c(pO2, T, S, P=0):
    """
    Convert oxygen partial pressure (mbar) to molar oxygen concentration (µmol/L).
    According to recommendations by SCOR WG 142 "Quality Control Procedures for Oxygen and Other Biogeochemical Sensors on Floats and Gliders"

    ARGS : 
        pO2 : float or array
            Oxygen partial pressure in mbar
        T : float or array
            Temperature in °C
        S : float or array
            Salinity (PSS-78)
        P : float or array, optional
            Hydrostatic pressure in dbar (default = 0)

    RETURNS : 
        O2conc : float or array
            Oxygen concentration in µmol/L
    """

    pO2 = np.asarray(pO2)
    T = np.asarray(T)
    S = np.asarray(S)
    P = np.asarray(P)

    # mole fraction of O2 in dry air (Glueckauf 1951)
    xO2 = 0.20946

    # saturated water vapor pressure in mbar
    pH2Osat = 1013.25 * np.exp(
        24.4543
        - 67.4509 * (100 / (T + 273.15))
        - 4.8489 * np.log((T + 273.15) / 100)
        - 0.000544 * S
    )

    # scaled temperature
    sca_T = np.log((298.15 - T) / (273.15 + T))

    # temperature correction part from Garcia and Gordon (1992), Benson and Krause (1984) refit mL(STP) L-1; and conversion from mL(STP) L-1 to umol L-1
    TCorr = 44.6596 * np.exp(
        2.00907
        + 3.22014 * sca_T
        + 4.05010 * sca_T**2
        + 4.94457 * sca_T**3
        - 2.56847e-1 * sca_T**4
        + 3.88767 * sca_T**5
    )

    # salinity correction part from Garcia and Gordon (1992), Benson and Krause (1984) refit ml(STP) L-1
    Scorr = np.exp(
        S * (
            -6.24523e-3
            - 7.37614e-3 * sca_T
            - 1.03410e-2 * sca_T**2
            - 8.17083e-3 * sca_T**3
        )
        - 4.88682e-7 * S**2
    )

    # constants
    Vm = 0.317   # molar volume of O2 in m3 mol-1 Pa dbar-1 (Enns et al. 1965)
    R  = 8.314   # universal gas constant in J mol-1 K-1

    # calculate molar oxygen concentration
    O2conc = (
        pO2 / (xO2 * (1013.25 - pH2Osat))
        * (TCorr * Scorr)
        / np.exp(Vm * P / (R * (T + 273.15)))
    )

    return O2conc

def o2p_to_o2s(pO2, T, S, P=0, p_atm=1013.25):
    """
    Convert oxygen partial pressure (mbar) to oxygen saturation (%).
    According to recommendations by SCOR WG 142 "Quality Control Procedures for Oxygen and Other Biogeochemical Sensors on Floats and Gliders"

    ARGS : 
        pO2 : float or array
            Oxygen partial pressure in mbar
        T : float or array
            Temperature in °C
        S : float or array
            Salinity (PSS-78)
        P : float or array, optional
            Hydrostatic pressure in dbar (default = 0). 
            (Note: included for API compatibility; not used in equation.)
        p_atm : float or array, optional
            Atmospheric pressure in mbar (default = 1013.25)

    RETURNS
        O2sat : float or array
            Oxygen saturation in %
    """

    pO2 = np.asarray(pO2)
    T = np.asarray(T)
    S = np.asarray(S)
    P = np.asarray(P)       # unused, but kept for completeness
    p_atm = np.asarray(p_atm)

    # constants
    xO2 = 0.20946 # mole fraction of O2 in dry air (Glueckauf 1951)

    # saturated water vapor pressure in mbar
    pH2Osat = 1013.25 * np.exp(
        24.4543
        - (67.4509 * (100 / (T + 273.15)))
        - (4.8489 * np.log((T + 273.15) / 100))
        - (0.000544 * S)
    )

    # Calculate oxygen saturation
    O2sat = pO2 * 100 / (xO2 * (p_atm - pH2Osat))

    return O2sat

def o2s_to_o2c(O2sat, T, S, P=0, p_atm=1013.25):
    """
    Convert oxygen saturation (%) to molar oxygen concentration (µmol/L).
    According to recommendations by SCOR WG 142 "Quality Control Procedures for Oxygen and Other Biogeochemical Sensors on Floats and Gliders"

    ARGS : 
        O2sat : float or array
            Oxygen saturation in %
        T : float or array
            Temperature (°C)
        S : float or array
            Salinity (PSS-78)
        P : float or array, optional
            Hydrostatic pressure in dbar (default = 0)
        p_atm : float or array, optional
            Atmospheric pressure in mbar (default = 1013.25)

    RETURNS
        O2conc : float or array
            Oxygen concentration in µmol/L
    """

    O2sat = np.asarray(O2sat)
    T = np.asarray(T)
    S = np.asarray(S)
    P = np.asarray(P)
    p_atm = np.asarray(p_atm)

    # saturated water vapor pressure in mbar
    pH2Osat = 1013.25 * np.exp(
        24.4543
        - 67.4509 * (100 / (T + 273.15))
        - 4.8489 * np.log((T + 273.15) / 100)
        - 0.000544 * S
    )

    # scaled temperature
    sca_T = np.log((298.15 - T) / (273.15 + T))

    # temperature correction part from Garcia and Gordon (1992), Benson and Krause (1984) refit mL(STP) L-1; and conversion from mL(STP) L-1 to umol L-1
    TCorr = 44.6596 * np.exp(
        2.00907
        + 3.22014 * sca_T
        + 4.05010 * sca_T**2
        + 4.94457 * sca_T**3
        - 2.56847e-1 * sca_T**4
        + 3.88767 * sca_T**5
    )

    # salinity correction part from Garcia and Gordon (1992), Benson and Krause (1984) refit ml(STP) L-1
    Scorr = np.exp(
        S * (
            -6.24523e-3
            - 7.37614e-3 * sca_T
            - 1.03410e-2 * sca_T**2
            - 8.17083e-3 * sca_T**3
        )
        - 4.88682e-7 * S**2
    )

    # constants
    Vm = 0.317   # molar volume of O2 in m3 mol-1 Pa dbar-1 (Enns et al. 1965)
    R  = 8.314   # universal gas constant in J mol-1 K-1

    # calculate molar oxygen concentration
    O2conc = (
        (O2sat / 100)
        * (TCorr * Scorr)
        * (p_atm - pH2Osat)
        / (1013.25 - pH2Osat)
        / np.exp(Vm * P / (R * (T + 273.15)))
    )

    return O2conc

def o2s_to_o2p(O2sat, T, S, P=0, p_atm=1013.25):
    """
    Convert oxygen saturation (%) to oxygen partial pressure (mbar).
    According to recommendations by SCOR WG 142 "Quality Control Procedures for Oxygen and Other Biogeochemical Sensors on Floats and Gliders"

    ARGS : 
        O2sat : float or array
            Oxygen saturation in %
        T : float or array
            Temperature in °C
        S : float or array
            Salinity (PSS-78)
        P : float or array, optional
            Hydrostatic pressure in dbar (default = 0). (Unused; kept for compatibility)
        p_atm : float or array, optional
            Atmospheric pressure in mbar (default = 1013.25)

    RETURNS : 
        pO2 : float or array
            Oxygen partial pressure in mbar
    """

    O2sat = np.asarray(O2sat)
    T = np.asarray(T)
    S = np.asarray(S)
    P = np.asarray(P)       # Unused parameter, included for API consistency
    p_atm = np.asarray(p_atm)

    # constants
    xO2 = 0.20946 # mole fraction of O2 in dry air (Glueckauf 1951)

    # saturated water vapor pressure in mbar
    pH2Osat = 1013.25 * np.exp(
        24.4543
        - (67.4509 * (100 / (T + 273.15)))
        - (4.8489 * np.log((T + 273.15) / 100))
        - (0.000544 * S)
    )

    # calculate partial pressure
    pO2 = (O2sat / 100) * (xO2 * (p_atm - pH2Osat))

    return pO2