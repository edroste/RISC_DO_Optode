import optode_functions.apply_oxygen_solubility_salinity_correction
import optode_functions.ph2o_weiss_price_1980 

from optode_functions.apply_oxygen_solubility_salinity_correction import apply_oxygen_solubility_salinity_correction
from optode_functions.ph2o_weiss_price_1980 import ph2o_weiss_price_1980

def apply_salinity_correction(MOLAR_DOXY, T, S, Spreset = 0): 
    """
    Apply salinity correction to molar oxygen concentrations according to Bittig et al. (2016). 

    ARGS: 
        MOLAR_DOXY: float or array-like
            Molar oxygen concentration calculated for salinity = 0 (umol L-1)
        T : float or array-like
            Temperature (degC)
        S : float or array-like
            Actual salinity 
        Spreset : float, optional
            Reference salinity (e.g., 0 for freshwater or 35 for preset seawater).

    RETURNS: 
        MOLAR_DOXY_PSAL : float or array-like
            Molar oxygen concentration corrected for actual salinity (umol L-1)
    
    """

    # Calculate factor with partial pressure of water vapour, following Weiss & PRice (1980)
    A = 1013.25 - ph2o_weiss_price_1980(S = Spreset, T = T) # 1 mbar = 1hPa 
    B = 1013.25 - ph2o_weiss_price_1980(S = S, T = T) # 1 mbar = 1hPa 

    S_Corr = apply_oxygen_solubility_salinity_correction(S = S, T = T, Spreset=0)

    MOLAR_DOXY_PSAL = (A/B) * S_Corr * MOLAR_DOXY

    return MOLAR_DOXY_PSAL

    