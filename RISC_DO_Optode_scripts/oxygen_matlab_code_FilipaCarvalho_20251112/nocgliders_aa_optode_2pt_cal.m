function [O2conc_uM,O2eq, O2sat] = nocgliders_aa_optode_2pt_cal(calStruc, optode_phase,temperature,salinity,pressure)
% Correct dissolved oxygen concentration on a slocum glider with an Aanderaa 4831 optode
% Uses sci_oxy4_calphase or drv_shifted_oxy4_calphase (after applying shift
% lag correction to the calphase dataset) to recompute oxygen concentration
% using manufacturers guidelines.
%
% Salinity and temperature corrections use CTD data as oposed to the optode
% temperature probe and the salinity=0 setting that optodes have by default
% Pressure correction also applied
%
% Inputs required are:
% - manufacturer calibration coefficients (run gocart_save_oxy_coeff.m)
% - shifted data ('yes' or 'no'), indicates which caphase dataset to use.
%   If a drv_shifted_sci_oxy4_calphase has been created (by evaluating the
%   shift lag between upcast and downcast), set shifted_calphase='yes'.
%  - plot_cor ('yes' or 'no'), creates a plot with the comparison between
%  glider output (sci_oxy4_oxygen) and corrected (and potentially lag
%  shifted) oxygen data
% - to force a certain salinity, set force_salinity to that number
% - temp lag difference betweern optode lag and temperature lag (analyses
% have shown 15 secs difference, so if calphase lag is 65, we also need to 
% apply a temperature shift of 50 seconds
%
% Created by Filipa Carvalho
% Adapted from aa4831_oxygen_correction_gdat.m written on April 12th, 2018
% Last edited by Filipa on July 9th, 2021

% find indices where we have oxy4_calphase
idx = find(optode_phase > 0 & ~isnan(temperature + salinity + pressure) & abs(salinity-20) <=20 );

dp(1:size(temperature),1)=nan;    
dp(idx)= calStruc.aa4831_FoilCoefA0 .* temperature(idx).^calStruc.m0 .* optode_phase(idx).^calStruc.n0 + ...
    calStruc.aa4831_FoilCoefA1 .* temperature(idx).^calStruc.m1 .* optode_phase(idx).^calStruc.n1 + ...
    calStruc.aa4831_FoilCoefA2 .* temperature(idx).^calStruc.m2 .* optode_phase(idx).^calStruc.n2 + ...
    calStruc.aa4831_FoilCoefA3 .* temperature(idx).^calStruc.m3 .* optode_phase(idx).^calStruc.n3 + ...
    calStruc.aa4831_FoilCoefA4 .* temperature(idx).^calStruc.m4 .* optode_phase(idx).^calStruc.n4 + ...
    calStruc.aa4831_FoilCoefA5 .* temperature(idx).^calStruc.m5 .* optode_phase(idx).^calStruc.n5 + ...
    calStruc.aa4831_FoilCoefA6 .* temperature(idx).^calStruc.m6 .* optode_phase(idx).^calStruc.n6 + ...
    calStruc.aa4831_FoilCoefA7 .* temperature(idx).^calStruc.m7 .* optode_phase(idx).^calStruc.n7 + ...
    calStruc.aa4831_FoilCoefA8 .* temperature(idx).^calStruc.m8 .* optode_phase(idx).^calStruc.n8 + ...
    calStruc.aa4831_FoilCoefA9 .* temperature(idx).^calStruc.m9 .* optode_phase(idx).^calStruc.n9 + ...
    calStruc.aa4831_FoilCoefA10 .* temperature(idx).^calStruc.m10 .* optode_phase(idx).^calStruc.n10 + ...
    calStruc.aa4831_FoilCoefA11 .* temperature(idx).^calStruc.m11 .* optode_phase(idx).^calStruc.n11 + ...
    calStruc.aa4831_FoilCoefA12 .* temperature(idx).^calStruc.m12 .* optode_phase(idx).^calStruc.n12 + ...
    calStruc.aa4831_FoilCoefA13 .* temperature(idx).^calStruc.m13 .* optode_phase(idx).^calStruc.n13 + ...
    calStruc.aa4831_FoilCoefB0 .* temperature(idx).^calStruc.m14 .* optode_phase(idx).^calStruc.n14 + ...
    calStruc.aa4831_FoilCoefB1 .* temperature(idx).^calStruc.m15 .* optode_phase(idx).^calStruc.n15 + ...
    calStruc.aa4831_FoilCoefB2 .* temperature(idx).^calStruc.m16 .* optode_phase(idx).^calStruc.n16 + ...
    calStruc.aa4831_FoilCoefB3 .* temperature(idx).^calStruc.m17 .* optode_phase(idx).^calStruc.n17 + ...
    calStruc.aa4831_FoilCoefB4 .* temperature(idx).^calStruc.m18 .* optode_phase(idx).^calStruc.n18 + ...
    calStruc.aa4831_FoilCoefB5 .* temperature(idx).^calStruc.m19 .* optode_phase(idx).^calStruc.n19 + ...
    calStruc.aa4831_FoilCoefB6 .* temperature(idx).^calStruc.m20 .* optode_phase(idx).^calStruc.n20 + ...
    calStruc.aa4831_FoilCoefB7 .* temperature(idx).^calStruc.m21 .* optode_phase(idx).^calStruc.n21 + ...
    calStruc.aa4831_FoilCoefB8 .* temperature(idx).^calStruc.m22 .* optode_phase(idx).^calStruc.n22 + ...
    calStruc.aa4831_FoilCoefB9 .* temperature(idx).^calStruc.m23 .* optode_phase(idx).^calStruc.n23 + ...
    calStruc.aa4831_FoilCoefB10 .* temperature(idx).^calStruc.m24 .* optode_phase(idx).^calStruc.n24 + ...
    calStruc.aa4831_FoilCoefB11 .* temperature(idx).^calStruc.m25 .* optode_phase(idx).^calStruc.n25 + ...
    calStruc.aa4831_FoilCoefB12 .* temperature(idx).^calStruc.m26 .* optode_phase(idx).^calStruc.n26 + ...
    calStruc.aa4831_FoilCoefB13 .* temperature(idx).^calStruc.m27 .* optode_phase(idx).^calStruc.n27; 

% Calcate vapour pressure
pvapour = NaN(size(temperature));
pvapour(idx)= exp( 52.57 - (6690.9./(temperature(idx) + 273.15)) - (4.681.*log(temperature(idx) + 273.15)) );

% Calculate Air Saturation
airsat = (dp .* 100)./((1013.25 - pvapour) .* 0.20946);

% Calculate scaled temperature
Ts = NaN(size(temperature));
Ts(idx) = log((298.15 - temperature(idx))./(273.15 + temperature(idx)));

% Benson and Krause coefficients 
A0 = 2.00856;
A1 = 3.22400;
A2 = 3.99063;
A3 = 4.80299;
A4 = 9.78188e-1;
A5 = 1.71069;
B0 = -6.24097e-3;
B1 = -6.93498e-3;
B2 = -6.90358e-3;
B3 = -4.29155e-3;
C0 = -3.11680e-7;

% Calculate oxygen solubility
%this is faster:
lnC = A0 + Ts.*(A1 + Ts.*(A2 + Ts.*(A3 + Ts.*(A4 + A5.*Ts)))) +...
    salinity .*(B0 + Ts.*(B1 + Ts.*(B2 + B3.*Ts))) + ...
    C0 .* salinity .* salinity;
solub = exp(lnC);


% Oxygen concentration calculated as:
MOLAR_DOXY = (solub .* 44.614 .* airsat) ./ 100;

% Calculate oxygen concentration (CTD temperature and salinity corrected,
% but not pressure)
o2conc_uM_uncorrected=calStruc.aa4831_ConcCoef0+calStruc.aa4831_ConcCoef1.*MOLAR_DOXY;

% O2 concentration (uM) after pressure correction:
O2conc_uM = o2conc_uM_uncorrected .* (1.0 + ((0.032 .* pressure) ./ 1000.0));

% Absolute salinity scale
SA = 35.16504./35.*salinity;
% scaled temperature
% conservative temperature
O2eq = gsw_O2sol_SP_pt(salinity,gsw_pt_from_t(SA,temperature,pressure));

O2sat = 100.*(O2conc_uM./O2eq);

