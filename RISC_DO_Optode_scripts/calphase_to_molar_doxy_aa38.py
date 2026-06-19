def calphase_to_molar_doxy_aa38_poly(CALPHASE_DOXY, T, cal_sheet_aa): 
    """
    Calculate dissolved oxygen concentration in umol L-1 from calibrated phase, for salinity = 0 (i.e., freshwater). 
    This function applies to Aanderaa optodes 3930, 3835, 3975, 4130, and 4175 (and 3830) only. 
    Use CTD temperature as temperature input! 
    
    ARGS: 
        CALPHASE_DOXY : float or array-like
            Calibrated phase shift (degrees)
        T : float or array-like
            Temperature in degC. Use CTD Temperature! 
        FoilCalCoef : float
            20 foil-dependant calibration coefficient. Each set is associated to each batch of foils. Provide by manufacturer. 

    RETURN: 
        MOLAR_DOXY : dissolved oxygen concentration in umol L-1 for salinity = 0
    """

    print("Note: Make sure input temperature is CTD temperature (ideally adjusted for geometric lag)!")

    C0 = cal_sheet_aa.FoilCalCoef0 + cal_sheet_aa.FoilCalCoef1*T  + cal_sheet_aa.FoilCalCoef2*T**2 + cal_sheet_aa.FoilCalCoef3*T**3
    C1 = cal_sheet_aa.FoilCalCoef4 + cal_sheet_aa.FoilCalCoef5*T  + cal_sheet_aa.FoilCalCoef6*T**2 + cal_sheet_aa.FoilCalCoef7*T**3
    C2 = cal_sheet_aa.FoilCalCoef8 + cal_sheet_aa.FoilCalCoef9*T  + cal_sheet_aa.FoilCalCoef10*T**2 + cal_sheet_aa.FoilCalCoef11*T**3
    C3 = cal_sheet_aa.FoilCalCoef12 + cal_sheet_aa.FoilCalCoef13*T  + cal_sheet_aa.FoilCalCoef14*T**2 + cal_sheet_aa.FoilCalCoef15*T**3
    C4 = cal_sheet_aa.FoilCalCoef16 + cal_sheet_aa.FoilCalCoef17*T  + cal_sheet_aa.FoilCalCoef18*T**2 + cal_sheet_aa.FoilCalCoef19*T**3

    MOLAR_DOXY = C0 + C1*CALPHASE_DOXY + C2*CALPHASE_DOXY**2 + C3*CALPHASE_DOXY**3 + C4*CALPHASE_DOXY**4

    return MOLAR_DOXY


def calphase_to_molar_doxy_aa38_svu(CALPHASE_DOXY, T, cal_sheet_aa): 
    """
    Compute dissolved oxygen (MOLAR_DOXY) from the calibrated phase shift (CALPHASE_DOXY) using the modified Stern–Volmer equation. 
    This equation uses 2 temperature-dependent coefficients that are each defined by 3-order polynomials based on coefficients provided by the manufacturer, 
    and 2 temperature-independent coefficients from the manufacturer. 

    ARGS: 
        CALPHASE_DOXY : float or array-like
            Calibrated phase shift (degrees). 
        T : float or array-like
            Temperature in degC. Use CTD Temperature! 
            
    RETURN: 
        MOLAR_DOXY : dissolved oxygen concentration in umol L-1 for salinity = 0
    """

    # Polynomial evaluations for K0(T) and K1(T)
    
    K0 = (
        cal_sheet_aa.K0_coeffs0
        + cal_sheet_aa.K0_coeffs1 * T
        + cal_sheet_aa.K0_coeffs2 * T**2
        + cal_sheet_aa.K0_coeffs3 * T**3
    )

    K1 = (
        cal_sheet_aa.K1_coeffs0
        + cal_sheet_aa.K1_coeffs1 * T
        + cal_sheet_aa.K1_coeffs2 * T**2
        + cal_sheet_aa.K1_coeffs3 * T**3
    )

    # Apply Stern–Volmer equation
    MOLAR_DOXY = (cal_sheet_aa.F1 / (K0 * CALPHASE_DOXY + cal_sheet_aa.F2) - 1.0) * K1

    return MOLAR_DOXY

def calphase_to_molar_doxy_aa38_svu_mod(): 
    """
    
    ARGS: 

            
    RETURN: 
        MOLAR_DOXY : dissolved oxygen concentration in umol L-1 for salinity = 0
    """

    print("Code for this method has not been written yet. ")
    MOLAR_DOXY = 0
    
    return MOLAR_DOXY

def calphase_to_molar_doxy_aa38(CALPHASE_DOXY, T, cal_sheet_aa, method = "poly"): 
    """

    ARGS: 
        CALPHASE_DOXY : float or array-like
            Calibrated phase shift (degrees)
        T : float or array-like
            Temperature in degC. Use CTD Temperature! 
        method: string
            Method for calculation. Choose from: "poly", "svu", or "svu-modified"
    
    """

    if method == "poly": 
        MOLAR_DOXY = calphase_to_molar_doxy_aa38_poly(CALPHASE_DOXY, T, cal_sheet_aa)
    elif method == "svu": 
        MOLAR_DOXY = calphase_to_molar_doxy_aa38_svu(CALPHASE_DOXY, T, cal_sheet_aa)
    elif method == "svu-modified":
        MOLAR_DOXY = calphase_to_molar_doxy_aa38_svu_mod(CALPHASE_DOXY, T, cal_sheet_aa)
    else: 
        print("ERROR: Does not recongise the method. Choose from 'poly', 'svu', or 'svu-modified'. ")


    return MOLAR_DOXY