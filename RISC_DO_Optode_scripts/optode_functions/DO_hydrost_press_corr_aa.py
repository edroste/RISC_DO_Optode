def DO_hydrost_press_corr_aa(MOLAR_DOXY_PSAL, P, T, optode_pipeline_settings):
    """
    Correct for hydrostatic pressure effect on quenching and membrane O2 equilibrium for Aanderaa optodes (also SeaBird optodes). 

    ARGS:
        MOLAR_DOXY_PSAL: array-like
            Salinity-corrected oxygen concentration. Unit = umol L-1. 
        P: array-like
            Pressure adjusted for geometric lag. Unit = dbar. 
        T: array-like
            Temperature from the CTD adjusted for geometric lag. Unit = degrees Celsius. 

    RETURNS: 
        MOLAR_DOXY_PSAL_PRES : array-like
            Pressure corrected oxygen concentration (umol L-1). 

    Sources:
        - Bittig et al. (2015): Bittig, H.C., B. Fielder, P. Fietzk and A. Kortzinger (2015): 
        Pressure Response of Aanderaa and Sea-Bird Oxygen Optodes. J. Atmos. Oceanic Tech., 
        32, 2305-2317, doi: 10.1175/JTECH-D-15-0108.1
        - Thierry et al. (2025a)
        
    """

    # Where did this equation come from? 
    # MOLAR_DOXY_PSAL_PRES = MOLAR_DOXY_PSAL *(1.0 + ((0.032 * P) / 1000))

    if optode_pipeline_settings.first_pcorr_applied == 1: 
        # If uncalibrated phase shift has been corrected for pressure effect # Bittig et al., 2018; Thierry et al., 2025a
        Pcoef2 = 0.00022 # 0.022 when working in bar
        Pcoef3 = 0.0419 # 4.19 when working in bar
    elif optode_pipeline_settings.first_pcorr_applied == 0: 
        # If uncalibrated phase shift has not been corrected for pressure effect # Thierry et al., 2025a
        Pcoef2 = 0.00025 # 0.025 when working in bar
        Pcoef3 = 0.0328 # 3.28 when working in bar
    else: 
        print("first_pcorr_applied in settings needs to be set to 0 (pressure correction on phase shift not applied) or 1 (pressure correction on phase shift applied).")
    
    MOLAR_DOXY_PSAL_PRES = MOLAR_DOXY_PSAL *(1.0 + ((Pcoef2 * T + Pcoef3) * P) / 1000)

    return MOLAR_DOXY_PSAL_PRES


    