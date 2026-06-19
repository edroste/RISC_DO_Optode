def calculate_dphase_aa(ds, UNCAL_PHASE_DOXY_PCORR, cal_sheet_aa): 
    """
    Determine DPHASE (i.e., calibrated phase) using 3rd degree polynomial and UNCAL_PHASE_Pcorr. 

    ARGS:
        PhaseCoef0-3: floats (saved in cal_sheet_aa, i.e., the manufacturer calibration sheet)
            Phase shift coefficients provided by the manufacturer
        UNCAL_PHASE_Pcorr : array-like
            Uncalibrated phase shift of the optode, which has ideally been corrected for pressure. Unit = deg. 
    RETURN:
        DPHASE_DOXY data array added to dataset 
    
    """
    A = cal_sheet_aa.PhaseCoef0
    B = cal_sheet_aa.PhaseCoef1
    C = cal_sheet_aa.PhaseCoef2
    D = cal_sheet_aa.PhaseCoef3

    CALPHASE_DOXY = A + (B*UNCAL_PHASE_DOXY_PCORR) + (C*UNCAL_PHASE_DOXY_PCORR**2) + (D*UNCAL_PHASE_DOXY_PCORR**3)

    return CALPHASE_DOXY
    