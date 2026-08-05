def phase_hydrost_press_corr(UNCAL_PHASE_DOXY, PRES_geoshift, optode_pipeline_settings, Pcoef1 = None): 
    """
    Apply hydrostatic pressure correction to optode phase measurements.

    Corrects the optode phase shift for the pressure-dependent change in
    luminescence lifetime caused by hydrostatic pressure. The correction is
    applied following Bittig et al. (2015), using a pressure coefficient
    (Pcoef1) that is sensor dependent. If no coefficient is provided, the
    appropriate value is selected automatically according to sensor type.

    Pressure correction should be applied after geometric alignment of pressure
    measurements to the optode location, such that ``PRES_geoshift`` represents
    the pressure experienced by the optode at the time of the phase measurement.

    Parameters
    ----------
    UNCAL_PHASE_DOXY : array-like
        Uncalibrated optode phase measurements. Units: degrees.
        For Aanderaa optodes, this corresponds to the raw phase variable
        (e.g. BPhase for 3830 optodes or TCPhase/TPhase for 4330 optodes).

    PRES_geoshift : array-like
        Pressure measurements corrected for geometric time offset between CTD
        and optode sensors. Units: dbar.

    optode_pipeline_settings : object
        Object containing optode configuration information, including:
        
        - ``uncal_phase_doxy``: name of the uncalibrated phase variable
        - ``sensor_type``: optode model identifier
        - ``Pcoef1_dict``: dictionary containing pressure coefficients
        - ``first_pcorr_applied``: processing flag indicating whether the
          correction has been applied

    Pcoef1 : float, optional
        Pressure correction coefficient. Units: degrees per 1000 dbar.
        If not provided, the coefficient is selected automatically based on
        the optode sensor type.

    Returns
    -------
    UNCAL_PHASE_DOXY_PCORR : array-like
        Pressure-corrected uncalibrated phase values.

    Raises
    ------
    ValueError
        If the uncalibrated phase variable exists but contains no valid data,
        or if the pressure data required for correction are unavailable.

    Notes
    -----
    The applied correction is:

        PHASE_corrected = PHASE + (Pcoef1 * PRESSURE) / 1000

    References
    ----------
    Bittig et al. (2015)
        Bittig, H.C., B. Fielder, P. Fietzk and A. Kortzinger (2015): Pressure Response 
        of Aanderaa and Sea-Bird Oxygen Optodes. J. Atmos. Oceanic Tech., 32, 2305-2317, doi: 10.1175/JTECH-D-15-0108.1

    Bittig et al. (2018)
        Bittig et al. (2018): Bittig, H.C.,. A. Körtzinger, C. Neill, E. van Ooijen, J. N. Plant, J. Hahn, 
        K. S. Johnson, B. Yang, and S. R. Emerson (2018): Oxygen Optode Sensors: Principle, Characterization, 
        Calibration and Application in the Ocean. Front. Mar. Sci., 4, 429, doi: 10.3389/fmars.2017.00429
    Thierry et al. (2025)
        Thierry et al. (2025): Thierry V., H. Bittig, D. Gilbert, T. Kobayashi, K. Sato, C. Schmid, 2025: 
        Processing Argo OXYGEN data at the DAC level, v2.3.4, http://dx.doi.org/10.13155/39795
    
    """

    # # Check that uncalibrated phase data exist in the dataset
    # if optode_pipeline_settings.uncal_phase_doxy not in ds.data_vars: 
        
    #     UNCAL_PHASE_DOXY_PCORR = np.float("NaN")
    #     optode_pipeline_settings.first_pcorr_applied = 0 # Change first_pcorr_applied to 1

    #     raise KeyError(f"{optode_pipeline_settings.uncal_phase_doxy} does not exist in the dataset. This pressure correction can only be applied to uncalibrated optode phase data. ")

    # Check that the variable contains actual measurements
    if np.all(np.isnan(UNCAL_PHASE_DOXY)):
        
        optode_pipeline_settings.first_pcorr_applied = 0

        raise ValueError(
            f"{optode_pipeline_settings.uncal_phase_doxy} exists but contains "
            "no valid data. Pressure correction cannot be applied."
        )

    # Check pressure availability
    if PRES_geoshift is None or np.all(np.isnan(PRES_geoshift)):
        optode_pipeline_settings.first_pcorr_applied = 0

        raise ValueError("Geometrically shifted pressure data are unavailable or contain no valid values. Pressure correction cannot be applied.")
    
    # Select pressure coefficient
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