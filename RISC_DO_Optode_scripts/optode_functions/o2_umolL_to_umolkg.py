import optode_functions.calculate_potential_density_teos10
from optode_functions.calculate_potential_density_teos10 import calculate_potential_density_teos10

def o2_umolL_to_umolkg(MOLAR_DOXY, T, S, P, lon = None, lat = None):
    """
    Convert oxygen from µmol/L to µmol/kg using potential density of seawater (kg L-1) referenced to a hydrostatic pressure of 0 dbar and using practical salinity.

    For potential debsity, Bittig et al. (2016) recommends using equation of state based on Fofonoff and Millard (1983) and Millero et al. (1980). 
    
    
    ARGS: 
        MOLAR_DOXY : array or float
            Oxygen concentration in µmol/L
        T : array or float
            Temperature (°C)
        S : array or float
            Practical salinity (psu)
        P : array or float
            Pressure (dbar)
        lon : array-like, float
            Longitude -360 to 360 degrees. Required if potential density is calculated according to TEOS10. 
        lat : array-like, float
            Latitude -90 to 90 degrees. Required if potential density is calculated according to TEOS10. 
    
    RETURNS: 
        DOXY : array or float
            Oxygen concentration in µmol/kg
    """
    # rho_kgm3 = calculate_potential_density_unesco(S, T)     # kg/m^3 # NOT YET IMPLEMENTED 
    rho_kgm3 = calculate_potential_density_teos10(S = S, T = T, P = P, lon = lon, lat = lat) # kg/m^3  # USING THIS ONE FOR NOW
    rho_kgl = rho_kgm3 / 1000.0         # convert to kg/L

    DOXY = MOLAR_DOXY / rho_kgl

    return DOXY