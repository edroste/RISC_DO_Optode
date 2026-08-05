import numpy as np
from matplotlib.path import Path

def regional_range_check(LAT, LON, TEMP_DOXY):
    """
    Apply regional range checks for TEMP_DOXY in the Red Sea and Mediterranean Sea.

    ARGS:
        LAT : float or array-like
            Latitude of observations (°N).
        LON : float or array-like
            Longitude of observations (°E).
        TEMP_DOXY : float or array-like
            Optode temperature (°C).

    RETURNS:
        qc_temp : ndarray
            QC flags for TEMP_DOXY (1 = good, 4 = bad).
    """

    lat = np.asarray(LAT, dtype=float)
    lon = np.asarray(LON, dtype=float)
    temp_doxy = np.asarray(TEMP_DOXY, dtype=float)

    # Initialize QC flags with "1" (good)
    qc_temp = np.ones_like(temp_doxy, dtype=int)

    # Define polygons for Red Sea and Mediterranean Sea
    red_sea_poly = Path([
        (10, 40),
        (20, 50),
        (30, 30),
        (10, 40)
    ])
    
    med_sea_poly = Path([
        (30, -6),
        (30, 40),
        (40, 35),
        (42, 20),
        (50, 15),
        (40, -5),
        (30, -6)
    ])
    
    # Check which points are inside each polygon
    points = np.column_stack((lat, lon))
    in_red_sea = red_sea_poly.contains_points(points)
    in_med_sea = med_sea_poly.contains_points(points)

    # Apply regional temperature ranges
    qc_temp[in_red_sea & ((temp_doxy < 21.7) | (temp_doxy > 40.0))] = 4
    qc_temp[in_med_sea & ((temp_doxy < 10.0) | (temp_doxy > 40.0))] = 4

    return qc_temp
