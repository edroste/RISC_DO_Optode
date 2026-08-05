import numpy as np

def global_range_check(DOXY, TEMP_DOXY):
    """
    Apply global range checks for DOXY and TEMP_DOXY.
    
    ARGS: 
        DOXY : float or array-like
            Oxygen concentration (µmol kg-1).
        TEMP_DOXY : float or array-like
            Optode temperature (°C).

    RETURNS: 
        qc_doxy : ndarray
            QC flags for DOXY (1 = good, 4 = bad).
        qc_temp : ndarray
            QC flags for TEMP_DOXY (1 = good, 4 = bad).
    """

    doxy = np.asarray(DOXY, dtype=float)
    temp_doxy = np.asarray(TEMP_DOXY, dtype=float)

    # Initialize QC flags with "1" (good)
    qc_doxy = np.ones_like(DOXY, dtype=int)
    qc_temp = np.ones_like(TEMP_DOXY, dtype=int)

    # Apply global range checks
    qc_doxy[(DOXY < -5) | (DOXY > 600)] = 4
    qc_temp[(TEMP_DOXY < -2.5) | (TEMP_DOXY > 40)] = 4

    return qc_doxy, qc_temp