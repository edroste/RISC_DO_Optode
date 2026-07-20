def phase_hydrost_press_corr(UNCAL_PHASE_DOXY, PRES_geoshift, optode_pipeline_settings, Pcoef1 = None): 
    """
    Correcting optode phase shift for hydrostatic pressure effect on luminescence lifetime. 
    Following best practice protocols, including Pcoef1 = 0.1 deg (Bittig et al., 2015). 

    
    ARGS:
        UNCAL_PHASE_DOXY: array-like
            Uncalibrated phase measurements. Unit = deg. 
            Thierry et al. (2025a): For 3830 optodes, PHASE = UNCAL_Phase = BPhase. For 4330 optodes, PHASE = TCPhase. 
        PRES_geoshift: array-like
            Pressure measurements that have previously been adjusted for geometric alignment with the optode. Unit = dbar. 
        Pcoef1 = float 
            Pressure correction coefficient. Unit = deg. Default = 0.1. 


    RETURN: 
        UNCAL_PHASE_Pcorr: array-like
            Uncalibrated phase shift values corrected for hydrostatic pressure effect. 
        
    Sources: 
        - Bittig et al. (2015): Bittig, H.C., B. Fielder, P. Fietzk and A. Kortzinger (2015): Pressure Response 
        of Aanderaa and Sea-Bird Oxygen Optodes. J. Atmos. Oceanic Tech., 32, 2305-2317, doi: 10.1175/JTECH-D-15-0108.1
        - Bittig et al. (2018): Bittig, H.C.,. A. Körtzinger, C. Neill, E. van Ooijen, J. N. Plant, J. Hahn, 
        K. S. Johnson, B. Yang, and S. R. Emerson (2018): Oxygen Optode Sensors: Principle, Characterization, 
        Calibration and Application in the Ocean. Front. Mar. Sci., 4, 429, doi: 10.3389/fmars.2017.00429
        - Thierry et al. (2025): Thierry V., H. Bittig, D. Gilbert, T. Kobayashi, K. Sato, C. Schmid, 2025: 
        Processing Argo OXYGEN data at the DAC level, v2.3.4, http://dx.doi.org/10.13155/39795
    """

    if optode_pipeline_settings.uncal_phase_doxy not in ds.data_vars: 
        
        UNCAL_PHASE_DOXY_PCORR = np.float("NaN")
        optode_pipeline_settings.first_pcorr_applied = 0 # Change first_pcorr_applied to 1

        raise KeyError(f"{optode_pipeline_settings.uncal_phase_doxy} does not exist in the dataset. This pressure correction can only be applied to uncalibrated optode phase data. ")
        

    else: 

        # Pressure correction coefficient (Pcoef1) differs per sensor
        if not Pcoef1: # If Pcoef1 argument = None, apply Pcoef1 from dictionary based on sensor type
            Pcoef1 = optode_pipeline_settings.Pcoef1_dict[optode_pipeline_settings.sensor_type]
            print("Hydrostatic pressure correction done with Pcoef1 = ", Pcoef1, "(", optode_pipeline_settings.sensor_type,")")
        else:
            print("Hydrostatic pressure correction done with GIVEN Pcoef1 = ", Pcoef1)
    
        # Apply hydrostatic pressure correction 
        UNCAL_PHASE_DOXY_PCORR = UNCAL_PHASE_DOXY + (Pcoef1*PRES_geoshift)/1000
    
        # Change first_pcorr_applied to 1
        optode_pipeline_settings.first_pcorr_applied = 1

    return UNCAL_PHASE_DOXY_PCORR