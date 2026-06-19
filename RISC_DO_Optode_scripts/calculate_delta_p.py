def calculate_delta_p(CALPHASE_DOXY, T, C, m, n): 
    """
    Calculate partial pressure of oxygen (Δp) from CALPHASE_DOXY, temperature, and polynomial calibration coefficients, specific for the foil given by the manufacturer. 
    
    Δp = Σ C[i] * t^m[i] * dphase^n[i]

    ARGS:
        CALPHASE_DOXY : float or array
            Calibrated phase shift from the optode corrected for pressure
        T : float or array 
            Temperature (°C)
        C : list or array of coefficients C0 ... C27
        m : list or array of polynomial degrees for temperature
        n : list or array of polynomial degrees for dphase

    RETURNS
        Δp : float or array
            Partial pressure of oxygen in hPa. 
    """
    
    C = np.asarray(C)
    m = np.asarray(m)
    n = np.asarray(n)

    terms = C * (T ** m) * (CALPHASE_DOXY ** n)
    
    return np.sum(terms)