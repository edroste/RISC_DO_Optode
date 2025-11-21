function AOU=nocgliders_oxygen_AOU(salinity, temperature, pressure, TEOS_vars)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nocgliders_oxygen_AOU:  Calculates aparent oxygen utilization  umol/kg.
% 
% INPUTS:
% TEOS_vars:    logic statement, whether T/S variables (absolute salinity 
%               and conservative temperature) are being used
% if TEOS=0;
% temperature:  in situ temperature in deg C (not potential temperature)
% salinity:     Practical Salinity  (PSS-78)                   [ unitless ]
% pressure:     pressure (db) for pressure correction 
%
% if TEOS=1;
% temperature:  temperature in deg C (not potential temperature)
% salinity:     Salinity (Optional) default = 0
% pressure:     pressure (db) for pressure correction 
%
% OUTPUT:
% AOU:           Oxygen concentration in micromol/kg
%
% DEPENDENCIES:
% GSW_TOOLBOX available from www.teos-10.org is required
%
% USAGE: 
% Example: 
% >> [O2,O2sat] = aa_optode_mp(CAL,42,5,35,1000)
%
%   O2 = 135.5585
%   O2sat = 44.0178
%
%
% AUTHOR: David Nicholson // dnicholson@whoi.edu // 10 JAN 2019
% original script: aa_optode_mp.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% pt  =  potential temperature (ITS-90) referenced               [ deg C ]
%         to one standard atmosphere (0 dbar).
          
absolute_salinity
potential_temp=gsw_pt0_from_t(gsw_SA_from_SP(salinity, pressure,LONall,LATall);

OXYEQall=gsw_O2sol_SP_pt(practival_salinity,potential_temp);