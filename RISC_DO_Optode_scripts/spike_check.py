def spike_check(values, P, var_type='DOXY'):
    """
    Apply spike detection to DOXY or TEMP_DOXY.

    ARGS:
        values : array-like
            The measurement values (DOXY in µmol/kg or TEMP_DOXY in °C).
        P : array-like
            Corresponding pressure values (dbar).
        var_type : str, optional
            Type of variable: 'DOXY' or 'TEMP_OXY'. Default is 'DOXY'.

    RETURNS:
        qc_flags : ndarray
            QC flags (1 = good, 4 = bad).
    """

    values = np.asarray(values, dtype=float)
    P = np.asarray(P, dtype=float)
    qc_flags = np.ones_like(values, dtype=int)

    # Compute spike test value for points where V1 and V3 exist
    for i in range(1, len(values) - 1):
        V1, V2, V3 = values[i - 1], values[i], values[i + 1]
        test_value = abs(V2 - (V3 + V1) / 2) - abs((V3 - V1) / 2)
        p = P[i]

        if var_type.upper() == 'DOXY':
            threshold = 50.0 if p < 500 else 25.0
        elif var_type.upper() == 'TEMP_DOXY':
            threshold = 6.0 if p < 500 else 2.0
        else:
            raise ValueError("var_type must be 'DOXY' or 'TEMP_DOXY'")

        if test_value > threshold:
            qc_flags[i] = 4

    return qc_flags