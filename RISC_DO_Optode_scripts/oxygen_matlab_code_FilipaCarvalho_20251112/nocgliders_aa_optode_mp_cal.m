function [O2,O2eq,O2sat] = nocgliders_aa_optode_mp_cal(calStruc, optode_phase,temperature,salinity,pressure)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AA_OPTODE_MP:  Calculates oxygen concentration in umol/kg from phase,
% temperature and salinity for a 4XXX series Aanderaa optode with factory 
% multipoint calibration.  Optional salinity and pressure corrections are
% also included.
% 
% INPUTS:
% calStruc:     Struct of calibration coefficients from AA cal sheet
% optode_phase: vector of optode phase measurements (calphase or dphase)
% temperature:  temperature in deg C (not potential temperature)
% salinity:     Salinity (Optional) default = 0
% pressure:     pressure (db) for pressure correction 
%
% OUTPUT:
% O2:           Oxygen concentration in micromol/kg
% O2sat:        Oxygen percent saturation (%) (100 = saturated)
%
% DEPENDENCIES:
% GSW_TOOLBOX available from www.teos-10.org is required
%
% USAGE: 
% Example: 
% >> CAL.SVU = [0.00357703;0.000151175;2.80811e-06;233.877;-0.27878;...
%       -57.6821;4.53682];
% >> [O2,O2sat] = aa_optode_mp(CAL,42,5,35,1000)
%
%   O2 = 135.5585
%   O2sat = 44.0178
%
%
% AUTHOR: David Nicholson // dnicholson@whoi.edu // 10 JAN 2019
% original script: aa_optode_mp.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nobs = length(optode_phase);
% Sensor salinity settings
% default is to assume sensor is set to 0. If set to 35 or other value,
% this must be included in calStruc.S0
if ~isfield(calStruc,'S0')
    calStruc.S0 = 0;
end

% two point linear adjustment params
if ~isfield(calStruc,'ConcCoef')
    calStruc.ConcCoef = [0 1];
end
% these should be the same for all optodes, so default values used if not
% specified. defaults are from Garcia Gordon 1992 Table 1 column 5

if ~isfield(calStruc,'SB')
    calStruc.SB = [-6.24097E-3;
        -6.93498E-3;
        -6.90358E-3;
        -4.29155E-3];
end
if ~isfield(calStruc,'SC')
    calStruc.SC = -3.11680E-7;
end
SB = squeeze(calStruc.SB);
SC = squeeze(calStruc.SC);

% Absolute salinity scale
SA = 35.16504./35.*salinity;
% scaled temperature
temps = log((298.15-temperature)./(273.15+temperature));
tempS_M = [ones(nobs,1),temps,temps.^2,temps.^3];
% conservative temperature
CT = gsw_CT_from_t(SA,temperature,pressure);
O2eq = gsw_O2sol_SP_pt(salinity,gsw_pt_from_t(SA,temperature,pressure));

% Uchida et al. 2008 Stern-Volmer based calbration mode

C = calStruc.SVU;
Ksv = C(1) + C(2).*temperature+C(3).*temperature.^2;
P0 = C(4) + C(5).*temperature;
PC = C(6) + C(7).*optode_phase;
optode_uM = ((P0./PC)-1)./Ksv;

optode_umolkg = 1000.*optode_uM./(1000+ gsw_sigma0(SA,CT));
p_fac = 1 + 0.032.*(pressure./1000);

% Salinity correction
Scorr = exp((salinity-calStruc.S0).*(tempS_M*SB)+SC.*(salinity.^2-calStruc.S0.^2));
O2_corr = p_fac.*optode_umolkg.*Scorr;

% two point calibration
O2 = calStruc.ConcCoef(1) + O2_corr.*calStruc.ConcCoef(2);
O2sat = 100.*(O2./O2eq);
end

