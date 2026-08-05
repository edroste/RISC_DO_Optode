import optode_functions.calculate_air_saturation
import optode_functions.calculate_delta_p
import optode_functions.calculate_vapour_pressure 
import optode_functions.oxygen_solubility_garcia_gordon_1992

from optode_functions.calculate_air_saturation import calculate_air_saturation
from optode_functions.calculate_delta_p import calculate_delta_p
from optode_functions.calculate_vapour_pressure import calculate_vapour_pressure
from optode_functions.oxygen_solubility_garcia_gordon_1992 import oxygen_solubility_garcia_gordon_1992

def calphase_to_molar_doxy_aa43_poly(CALPHASE_DOXY, T, S, cal_sheet_aa): 
    """
    Calculate dissolved oxygen concentration in umol L-1 from calibrated phase, for salinity = 0 (i.e., freshwater), using the standard polynomial calibration method. 
    This function applies to Aanderaa optodes 4330, 4831, and 4835 only. 
    Use temperature from the optode as temperature input: TEMP_DOXY. 

    ARGS : 
        CALPHASE_DOXY: float or array-like
            Calibrated phase shift in degrees. 
        T: float or array-like
            Temperature in degC. Use TEMP_DOXY (i.e. optode temperature). 
        S: float or array-like
            Practical salinity from CTD geometrically aligned with the optode. 
        Manufacturer calibration sheet: 
        method : string either, "SVU" or "poly"
            "SVU" signifies that the SVU method will be applied to calculate molar concentration of oxygen. 
            This is only possible of SVUFoilCoef0-6 are available in the manufacturer calibration sheet. 
            "poly" signifies that the molar oxygen concentration for oxygen will be calculated using oxygen solubility and air saturation. 
            The latter depends on the partial pressure of oxygen, which requires 27 polynomial coefficients from the manufacturer. 

    RETURN: 
        MOLAR_DOXY: Oxygen concentration in umol L-1 for salinity = 0. 
    
    """
    
    # Read in all foil coefficients
    c0 = cal_sheet_aa.FoilCoefA0
    c1 = cal_sheet_aa.FoilCoefA1
    c2 = cal_sheet_aa.FoilCoefA2
    c3 = cal_sheet_aa.FoilCoefA3
    c4 = cal_sheet_aa.FoilCoefA4
    c5 = cal_sheet_aa.FoilCoefA5
    c6 = cal_sheet_aa.FoilCoefA6
    c7 = cal_sheet_aa.FoilCoefA7
    c8 = cal_sheet_aa.FoilCoefA8
    c9 = cal_sheet_aa.FoilCoefA9
    c10 = cal_sheet_aa.FoilCoefA10
    c11 = cal_sheet_aa.FoilCoefA11
    c12 = cal_sheet_aa.FoilCoefA12
    c13 = cal_sheet_aa.FoilCoefA13
    c14 = cal_sheet_aa.FoilCoefB0
    c15 = cal_sheet_aa.FoilCoefB1
    c16 = cal_sheet_aa.FoilCoefB2
    c17 = cal_sheet_aa.FoilCoefB3
    c18 = cal_sheet_aa.FoilCoefB4
    c19 = cal_sheet_aa.FoilCoefB5
    c20 = cal_sheet_aa.FoilCoefB6
    c21 = cal_sheet_aa.FoilCoefB7
    c22 = cal_sheet_aa.FoilCoefB8
    c23 = cal_sheet_aa.FoilCoefB9
    c24 = cal_sheet_aa.FoilCoefB10
    c25 = cal_sheet_aa.FoilCoefB11
    c26 = cal_sheet_aa.FoilCoefB12
    c27 = cal_sheet_aa.FoilCoefB13

    # Read in all polynomial degrees for temperature
    m0 = cal_sheet_aa.FoilPolyDegT0
    m1 = cal_sheet_aa.FoilPolyDegT1
    m2 = cal_sheet_aa.FoilPolyDegT2
    m3 = cal_sheet_aa.FoilPolyDegT3
    m4 = cal_sheet_aa.FoilPolyDegT4
    m5 = cal_sheet_aa.FoilPolyDegT5
    m6 = cal_sheet_aa.FoilPolyDegT6
    m7 = cal_sheet_aa.FoilPolyDegT7
    m8 = cal_sheet_aa.FoilPolyDegT8
    m9 = cal_sheet_aa.FoilPolyDegT9
    m10 = cal_sheet_aa.FoilPolyDegT10
    m11 = cal_sheet_aa.FoilPolyDegT11
    m12 = cal_sheet_aa.FoilPolyDegT12
    m13 = cal_sheet_aa.FoilPolyDegT13
    m14 = cal_sheet_aa.FoilPolyDegT14
    m15 = cal_sheet_aa.FoilPolyDegT15
    m16 = cal_sheet_aa.FoilPolyDegT16
    m17 = cal_sheet_aa.FoilPolyDegT17
    m18 = cal_sheet_aa.FoilPolyDegT18
    m19 = cal_sheet_aa.FoilPolyDegT19
    m20 = cal_sheet_aa.FoilPolyDegT20
    m21 = cal_sheet_aa.FoilPolyDegT21
    m22 = cal_sheet_aa.FoilPolyDegT22
    m23 = cal_sheet_aa.FoilPolyDegT23
    m24 = cal_sheet_aa.FoilPolyDegT24
    m25 = cal_sheet_aa.FoilPolyDegT25
    m26 = cal_sheet_aa.FoilPolyDegT26
    m27 = cal_sheet_aa.FoilPolyDegT27

    # Read in all polynomial degrees for oxygen
    n0 = cal_sheet_aa.FoilPolyDegO0
    n1 = cal_sheet_aa.FoilPolyDegO1
    n2 = cal_sheet_aa.FoilPolyDegO2
    n3 = cal_sheet_aa.FoilPolyDegO3
    n4 = cal_sheet_aa.FoilPolyDegO4
    n5 = cal_sheet_aa.FoilPolyDegO5
    n6 = cal_sheet_aa.FoilPolyDegO6
    n7 = cal_sheet_aa.FoilPolyDegO7
    n8 = cal_sheet_aa.FoilPolyDegO8
    n9 = cal_sheet_aa.FoilPolyDegO9
    n10 = cal_sheet_aa.FoilPolyDegO10
    n11 = cal_sheet_aa.FoilPolyDegO11
    n12 = cal_sheet_aa.FoilPolyDegO12
    n13 = cal_sheet_aa.FoilPolyDegO13
    n14 = cal_sheet_aa.FoilPolyDegO14
    n15 = cal_sheet_aa.FoilPolyDegO15
    n16 = cal_sheet_aa.FoilPolyDegO16
    n17 = cal_sheet_aa.FoilPolyDegO17
    n18 = cal_sheet_aa.FoilPolyDegO18
    n19 = cal_sheet_aa.FoilPolyDegO19
    n20 = cal_sheet_aa.FoilPolyDegO20
    n21 = cal_sheet_aa.FoilPolyDegO21
    n22 = cal_sheet_aa.FoilPolyDegO22
    n23 = cal_sheet_aa.FoilPolyDegO23
    n24 = cal_sheet_aa.FoilPolyDegO24
    n25 = cal_sheet_aa.FoilPolyDegO25
    n26 = cal_sheet_aa.FoilPolyDegO26
    n27 = cal_sheet_aa.FoilPolyDegO27

    # Put all coefficients and polynomial degrees into lists
    C = [c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c13, c14, 
        c15, c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27]
    m = [m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m13, m14, 
        m15, m16, m17, m18, m19, m20, m21, m22, m23, m24, m25, m26, m27]
    n = [n0, c1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n13, n14, 
        n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27]

    C_star = oxygen_solubility_garcia_gordon_1992(T = T, S = S) # oxygen solubility (cm3/dm3), calculated from Garcia & Gordon (1992)
    
    delta_p = calculate_delta_p(CALPHASE_DOXY = CALPHASE_DOXY, T = T, C = C, m = m, n = n) # calculate the partial pressure of oxygen (hPa)
    p_vapour = calculate_vapour_pressure(T) # calculate water vapour pressure (hPa)
    AirSaturation = calculate_air_saturation(delta_p, p_vapour) # calculate air saturation (%)
    
    MOLAR_DOXY_ = (C_star * 44.659 * AirSaturation) / 100 # calculate molar oxygen concentration for salinity = 0, not yet corrected with final calibration

    # Optional two-point adjustment. Set ConcCoef1 = 1 and ConcCoef0 = 0 if this adjustment shouldn't be applied. 
    MOLAR_DOXY = MOLAR_DOXY_ * cal_sheet_aa.ConcCoef1 + cal_sheet_aa.ConcCoef0 # Calculate corrected molar oxygen concentration for salinity = 0

    return MOLAR_DOXY

def calphase_to_molar_doxy_aa43_svu(CALPHASE_DOXY, T, cal_sheet_aa): 
    """
    Calculate dissolved oxygen concentration in umol L-1 from calibrated phase, for salinity = 0 (i.e., freshwater), using the SVU method. 
    This method is only possible of SVUFoilCoef0-6 are available in the manufacturer calibration sheet. 
    This function applies to Aanderaa optodes 4330, 4831, and 4835 only. 
    Use temperature from the optode for temperature input: TEMP_DOXY

    ARGS : 
        CALPHASE_DOXY: float or array-like
            Calibrated phase shift in degrees. 
        T: float or array-like
            Temperature in degC. Use TEMP_DOXY (i.e. optode temperature). 
        S: float or array-like
            Practical salinity from CTD geometrically aligned with the optode. 
        Manufacturer calibration sheet: 

    RETURN: 
        MOLAR_DOXY: Oxygen concentration in umol L-1 for salinity = 0. 
    
    """
    
    # Find teh SVU Foil Coefficients 
    c0 = cal_sheet_aa.SVUFoilCoef0
    c1 = cal_sheet_aa.SVUFoilCoef1
    c2 = cal_sheet_aa.SVUFoilCoef2
    c3 = cal_sheet_aa.SVUFoilCoef3
    c4 = cal_sheet_aa.SVUFoilCoef4
    c5 = cal_sheet_aa.SVUFoilCoef5
    c6 = cal_sheet_aa.SVUFoilCoef6
    
    K_SV = c0 + c1*T + c2*T**2
    P0 = c3 + c4*T
    Pc = c5 + c6*CALPHASE_DOXY # Use pressure corrected DPHASE

    # Apply Stern-Volmer equation
    MOLAR_DOXY_ = ((P0 / Pc) - 1) / K_SV

    # Optional two-point adjustment. Set ConcCoef1 = 1 and ConcCoef0 = 0 if this adjustment shouldn't be applied. 
    MOLAR_DOXY = MOLAR_DOXY_ * cal_sheet_aa.ConcCoef1 + cal_sheet_aa.ConcCoef0 # Calculate corrected molar oxygen concentration for salinity = 0

    return MOLAR_DOXY

def calphase_to_molar_doxy_aa43_svu_mod(): 
    """
    
    ARGS: 

            
    RETURN: 
        MOLAR_DOXY : dissolved oxygen concentration in umol L-1 for salinity = 0
    """

    print("Code for this method has not been written yet. ")
    MOLAR_DOXY = 0
    
    return MOLAR_DOXY

def calphase_to_molar_doxy_aa43(CALPHASE_DOXY, T, cal_sheet_aa, S = None, method = "svu"): 
    """
     Calculate dissolved oxygen concentration in umol L-1 from calibrated phase, for salinity = 0 (i.e., freshwater), using the SVU method. 
    This method is only possible of SVUFoilCoef0-6 are available in the manufacturer calibration sheet. 
    This function applies to Aanderaa optodes 4330, 4831, and 4835 only. 
    Use temperature from the optode for temperature input: TEMP_DOXY

    ARGS : 
        CALPHASE_DOXY: float or array-like
            Calibrated phase shift in degrees. 
        T: float or array-like
            Temperature in degC. Use TEMP_DOXY (i.e. optode temperature). 
        S: float or array-like
            Practical salinity from CTD geometrically aligned with the optode. S needs to be given if method = poly or poly-2point. 
        method : string
            Method must be 'poly', 'svu', 'svu-modified'
        cal_sheet_aa : Manufacturer calibration sheet: 

    RETURN: 
        MOLAR_DOXY: Oxygen concentration in umol L-1 for salinity = 0. 


    ARGS: 
        CALPHASE_DOXY : float or array-like
            Calibrated phase shift (degrees)
        T : float or array-like
            Temperature in degC. Use CTD Temperature! 
        method: string
            Method for calculation. Choose from: "poly", "poly-2point", "svu", "svu-2point", or "svu-modified"
    
    """

    if method == "poly": 
        MOLAR_DOXY = calphase_to_molar_doxy_aa43_poly(CALPHASE_DOXY, T, S, cal_sheet_aa)
    elif method == "svu": # choose this one if svu coefficients are available
        MOLAR_DOXY = calphase_to_molar_doxy_aa43_svu(CALPHASE_DOXY, T, cal_sheet_aa)
    elif method == "svu-modified":
        MOLAR_DOXY = calphase_to_molar_doxy_aa43_svu_mod(CALPHASE_DOXY, T, cal_sheet_aa)
    else: 
        print("ERROR: Does not recongise the method. Choose from 'poly', 'poly-2point', 'svu', 'svu-2point', or 'svu-modified'. ")


    return MOLAR_DOXY