def calculate_potential_density_teos10(S, T, P, lon, lat): 
    """
    Calculate potential density of seawater (kg L-1) referenced to a hydrostatic pressure of 0 dbar and using practical salinity.
    Using the Gibbs Seawater Python implementation of the Thermodynamic Equation of Seawater 2010 (TEOS-10). 

    ARGS: 
        T : array-like, float
            Temperature in degrees Celsius
        S : array-like, float
            Practical salinity 
        P : array-like, float
            Pressure in dbar. 
        lon : array-like, float
            Longitude -360 to 360 degrees
        lat : array-like, float
            Latitude -90 to 90 degrees

    RETURN: 
        rho : potential density of seawater in kg L-1. 
    """

    # Calculate absolute salinity
    SA = gsw.conversions.SA_from_SP(S, P, lon, lat)

    # Calculate conservative temperature
    CT = gsw.conversions.CT_from_t(SA, T, P)

    # Calculate potential density = potential density anomaly + 1000 kg m-3
    rho = gsw.density.sigma0(SA, CT) + 1000 # kg m-3


    return rho