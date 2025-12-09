# Settings for the Dissolved Oxygen pipeline

# ==========================================================================
# General 

# Sensor type 
sensor_type = "" #


# ==========================================================================
# Geometric lag alignment

# Default geometric time lag from 
geo_time_lag = 3.9450 # Default from Woo & Gourcurr, 2023 - IMOS. Set to "derive" if geometric time lag needs to be derived from glider pitch and vertical velocity

# Distance between CTD and DO optode on the glider
distance_CTD_optode = 90 # in cm                                              }

# Default geometric time lag from 
geo_time_lag = 3.9450 # Default from Woo & Gourcurr, 2023 - IMOS. Set to "derive" if geometric time lag needs to be derived from glider pitch and vertical velocity

# Distance between CTD and DO optode on the glider
distance_CTD_optode = 90 # in cm 


# ==========================================================================
# Coefficients for corrections (not included in manufacturer calibration sheets) 

# Dictionary with Pcoef1 per sensor - TO DO: complete 
Pcoef1_dict = {"aa4831": 0.1, # deg
               "aa3830": 0.1, # deg
               "sbe63": 0.115, # usec
               "": None, # 
              }

# Pressure correction coefficient
Pcoef1 = Pcoef1_dict[sensor_type] 

# Variable determining if first pressure correction has been applied 0 = no, 1 = yes

first_pcorr_applied = 0

# ==========================================================================
# Variable variables - can be changed during the runs

uncal_phase_doxy = "UNCAL_PHASE_DOXY" # default
uncal_phase_doxy_pcorr = "UNCAL_PHASE_DOXY_PCORR" # default
calphase_doxy = "CAL_PHASE_DOXY" # default
