function [gdat, psetup, gsetup] = nocgliders_oxygen_2pt_cal(gdat, psetup, gsetup)








function gdat=aa4831_oxygen_correction_gdat(time, salinity, temperature, calphase, pressure, oxy_cals, shifted_data, plot_oxy_cor, calphase_lag, temp_lag_delta)
%% Correct dissolved oxygen concentration on a slocum glider with an Aanderaa 4831 optode
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
% Written on April 12th, 2018
% Last edited by Filipa on May 9th, 2019

gdat.drv_mtime_sci=time;
gdat.drv_temperature=real(running_median(temperature,11,1));
% shifted_ts=shiftTimeSeries([gdat.drv_mtime_sci,gdat.drv_temperature],calphase_lag+temp_lag_delta);
% gdat.drv_temperature_shifted=shifted_ts(:,2);
% gdat.temperature=gdat.drv_temperature_shifted;

gdat.drv_calphase=calphase;
gdat.drv_pressure_sci=fillMissingValues(pressure);

gdat.drv_salinity=salinity;
gdat.salinity=real(running_median(gdat.drv_salinity,11,1));



% shift CTD data
shifted_ts=shiftTimeSeries([gdat.drv_mtime_sci,gdat.drv_temperature],calphase_lag+temp_lag_delta);
gdat.drv_temperature_shifted=shifted_ts(:,2);
shifted_ts=shiftTimeSeries([gdat.drv_mtime_sci,gdat.drv_salinity],calphase_lag+temp_lag_delta);
gdat.drv_salinity_shifted=shifted_ts(:,2);

ctd_vnames = {'drv_salinity_shifted','drv_pressure_sci','drv_temperature_shifted'};
gdat.timestamp_interp=fillMissingValues(gdat.drv_mtime_sci);
for vix = 1:length(ctd_vnames)
    vname = ctd_vnames{vix};
    g = ~isnan(gdat.(vname)) & ~isnan(gdat.timestamp_interp);
    gdat.([vname '_interp']) = interp1(gdat.timestamp_interp(g),gdat.(vname)(g),gdat.timestamp_interp);
end

% find indices where we have oxy4_calphase
idx = find(gdat.drv_calphase_shifted_interp > 0 & ~isnan(gdat.drv_temperature_shifted_interp + gdat.drv_salinity_shifted_interp + gdat.drv_pressure_sci_interp) & abs(gdat.drv_salinity_shifted_interp-20) <=20 );
% idx=find(a(:,1));

CalPhase_corrected=gdat.calphase;


% Load optode coefficients
load(oxy_cals);

dp(1:size(gdat.drv_temperature_shifted_interp),1)=nan;    
dp(idx)= calibs.aa4831_FoilCoefA0 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m0 .* CalPhase_corrected(idx).^calibs.n0 + ...
    calibs.aa4831_FoilCoefA1 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m1 .* CalPhase_corrected(idx).^calibs.n1 + ...
    calibs.aa4831_FoilCoefA2 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m2 .* CalPhase_corrected(idx).^calibs.n2 + ...
    calibs.aa4831_FoilCoefA3 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m3 .* CalPhase_corrected(idx).^calibs.n3 + ...
    calibs.aa4831_FoilCoefA4 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m4 .* CalPhase_corrected(idx).^calibs.n4 + ...
    calibs.aa4831_FoilCoefA5 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m5 .* CalPhase_corrected(idx).^calibs.n5 + ...
    calibs.aa4831_FoilCoefA6 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m6 .* CalPhase_corrected(idx).^calibs.n6 + ...
    calibs.aa4831_FoilCoefA7 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m7 .* CalPhase_corrected(idx).^calibs.n7 + ...
    calibs.aa4831_FoilCoefA8 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m8 .* CalPhase_corrected(idx).^calibs.n8 + ...
    calibs.aa4831_FoilCoefA9 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m9 .* CalPhase_corrected(idx).^calibs.n9 + ...
    calibs.aa4831_FoilCoefA10 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m10 .* CalPhase_corrected(idx).^calibs.n10 + ...
    calibs.aa4831_FoilCoefA11 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m11 .* CalPhase_corrected(idx).^calibs.n11 + ...
    calibs.aa4831_FoilCoefA12 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m12 .* CalPhase_corrected(idx).^calibs.n12 + ...
    calibs.aa4831_FoilCoefA13 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m13 .* CalPhase_corrected(idx).^calibs.n13 + ...
    calibs.aa4831_FoilCoefB0 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m14 .* CalPhase_corrected(idx).^calibs.n14 + ...
    calibs.aa4831_FoilCoefB1 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m15 .* CalPhase_corrected(idx).^calibs.n15 + ...
    calibs.aa4831_FoilCoefB2 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m16 .* CalPhase_corrected(idx).^calibs.n16 + ...
    calibs.aa4831_FoilCoefB3 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m17 .* CalPhase_corrected(idx).^calibs.n17 + ...
    calibs.aa4831_FoilCoefB4 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m18 .* CalPhase_corrected(idx).^calibs.n18 + ...
    calibs.aa4831_FoilCoefB5 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m19 .* CalPhase_corrected(idx).^calibs.n19 + ...
    calibs.aa4831_FoilCoefB6 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m20 .* CalPhase_corrected(idx).^calibs.n20 + ...
    calibs.aa4831_FoilCoefB7 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m21 .* CalPhase_corrected(idx).^calibs.n21 + ...
    calibs.aa4831_FoilCoefB8 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m22 .* CalPhase_corrected(idx).^calibs.n22 + ...
    calibs.aa4831_FoilCoefB9 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m23 .* CalPhase_corrected(idx).^calibs.n23 + ...
    calibs.aa4831_FoilCoefB10 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m24 .* CalPhase_corrected(idx).^calibs.n24 + ...
    calibs.aa4831_FoilCoefB11 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m25 .* CalPhase_corrected(idx).^calibs.n25 + ...
    calibs.aa4831_FoilCoefB12 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m26 .* CalPhase_corrected(idx).^calibs.n26 + ...
    calibs.aa4831_FoilCoefB13 .* gdat.drv_temperature_shifted_interp(idx).^calibs.m27 .* CalPhase_corrected(idx).^calibs.n27; 
% end
% Calcate vapour pressure
pvapour = NaN(size(gdat.drv_temperature_shifted_interp));
pvapour(idx)= exp( 52.57 - (6690.9./(gdat.drv_temperature_shifted_interp(idx) + 273.15)) - (4.681.*log(gdat.drv_temperature_shifted_interp(idx) + 273.15)) );

% Calculate Air Saturation
airsat = (dp .* 100)./((1013.25 - pvapour) .* 0.20946);

% Calculate scaled temperature
Ts = NaN(size(gdat.drv_temperature_shifted));
Ts(idx) = log((298.15 - gdat.drv_temperature_shifted_interp(idx))./(273.15 + gdat.drv_temperature_shifted_interp(idx)));

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
    gdat.drv_salinity_shifted_interp .*(B0 + Ts.*(B1 + Ts.*(B2 + B3.*Ts))) + ...
    C0 .* gdat.drv_salinity_shifted_interp .* gdat.drv_salinity_shifted_interp;
solub = exp(lnC);


% Oxygen concentration calculated as:
MOLAR_DOXY = (solub .* 44.614 .* airsat) ./ 100;

% Calculate oxygen concentration (CTD temperature and salinity corrected,
% but not pressure)
o2conc_uM_uncorrected=calibs.aa4831_ConcCoef0+calibs.aa4831_ConcCoef1.*MOLAR_DOXY;

% O2 concentration (uM) after pressure correction:
o2conc_uM = o2conc_uM_uncorrected .* (1.0 + ((0.032 .* gdat.drv_pressure_sci_interp) ./ 1000.0));

gdat.drv_oxygen_shifted=o2conc_uM;


% plot data
if strcmp(plot_oxy_cor, 'yes')
    p1=plot(gdat.sci_oxy4_oxygen, -gdat.drv_pressure_sci_interp,'.');
    hold on; grid on
    p3=plot(o2conc_uM, -gdat.drv_pressure_sci_interp,'r.');
    legend([p1,p3],{'sci_oxy4_oxygen (uM)',['o2conc_uM (T,S,P corrected' tc ')']}, ...
        'location', 'southeast', 'interpreter', 'none')
end


disp('Finished correcting drv_oxygen_correction')