def ph2o_weiss_price_1980(S, T): 
    """ 
    Calculate the partial pressure of water vapour, following Weiss & Price (1980). 
    Range 273 to 313K and 0--40% salinity
    Standard error of 0.015% of pH2O, an average of about 5 × 10 -6 atm 
    over this range (Weiss&Price, 1980)

    ARGS: 
        S : float or array-like 
            Salinity (practical)
        T : float or array-like
            Temperature (degC). 

    RETURNS: 
        ph2o : float or array-like
            Partial pressure of water vapour (mbar). 

    CITATION: 
        Weiss, R. F., & Price, B. A. (1980). Nitrous oxide solubility in water 
    and seawater. Marine chemistry, 8(4), 347-359.
    """

    T = T+273.15 # Convert degrees C to Kelvin
    
    # Constants from polynomial equation 10 in Weiss&Price, 1980.
    A = 24.4543
    B = -67.4509
    C = -4.8489
    D = -0.000544
    
    # Equation 10 in Weiss&Price, 1980
    ph2o = 1013.25 * np.exp(A + B*(100/T) + C*np.log(T/100) + D*S)
    
    return ph2o
