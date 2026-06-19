def temp_doxy_voltage_to_degC_aa(TEMP_VOLTAGE_DOXY, cal_sheet_aa):
    """
    Convert thermistor voltage of oxygen optode to degrees Celsius using manufacturer coefficients. 
    Applies to Aanderaa 3830 and 4330. 

    Source: Thierry et al. (2025a). Processing Argo Oxygen data at the DAC level: https://dx.doi.org/10.13155/39795 

    ARGS:
        TEMP_VOLTAGE_DOXY: array-like
            Thermistor voltage in volts. 
        cal_sheet_aa: 
            Calibration sheet with manufacturer calibration coefficients. 

    RETURN:
        TEMP_DOXY: array-like
            Optode temperature in degrees Celsius. 
    """
    T0 = cal_sheet_aa.TempCoef0
    T1 = cal_sheet_aa.TempCoef1
    T2 = cal_sheet_aa.TempCoef2
    T3 = cal_sheet_aa.TempCoef3
    T4 = cal_sheet_aa.TempCoef4
    T5 = cal_sheet_aa.TempCoef5

    TEMP_DOXY = T0 + (T1*TEMP_VOLTAGE_DOXY) + (T2*TEMP_VOLTAGE_DOXY**2) + (T3*TEMP_VOLTAGE_DOXY**3) + (T4*TEMP_VOLTAGE_DOXY**4) + (T5*TEMP_VOLTAGE_DOXY**5)
    

    return TEMP_DOXY