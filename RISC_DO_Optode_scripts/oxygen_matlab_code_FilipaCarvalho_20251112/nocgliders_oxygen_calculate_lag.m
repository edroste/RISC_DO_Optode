function oxygen_lags=nocgliders_oxygen_calculate_lag(gdat, psetup, sensor, shifts)
% This script calculates the best shift for the oxygen sensor (using
% calphase).
% each section allows different profiles to be considered:
% - upcast vs downcast (rutgers improvement over the regular dbdgroup
% determination written by J Kerfoot)
% - downcast vs upcast (cases where oxycline is deeper than 500m
% - a combination of both (cases where oxycline is roughly at 500m - it
% maximises the number of profile comparisons if we can use the same
% profile and compare it to the previous and the following profiles.
% Written in Nov 2018 by Filipa Carvalho
% Edited (combination comparison added) on Feb 2019
% sensor default is multipoint corrected oxygen (before lag correction)

% options for profile comparison
% up vs down & down vs up
% top X metres of up vs down and bottom X metres of down vs up
% 

mtime='drv_mtime';
if nansum(~isnan(gdat.(sensor)))==0
    sensor='sci_oxy4_oxygen';
end
raw_data=[gdat.(mtime), gdat.(sensor)];

clear tmp.shifted_ts results uMean dMean
results_UPvsDOWN_and_DOWNvsUP=nan(length(shifts),2,length(gdat.profiles)-1);
bestShifts_UPvsDOWN_and_DOWNvsUP=nan(length(gdat.profiles)-1,2);
results_UPvsDOWN=nan(length(shifts),2,length(gdat.profiles)-1);
bestShifts_UPvsDOWN=nan(length(gdat.profiles)-1,2);
results_DOWNvsUP=nan(length(shifts),2,length(gdat.profiles)-1);
bestShifts_DOWNvsUP=nan(length(gdat.profiles)-1,2);
results_UPvsDOWN_and_DOWNvsUP_500m=nan(length(shifts),2,length(gdat.profiles)-1);
bestShifts_UPvsDOWN_and_DOWNvsUP_500m=nan(length(gdat.profiles)-1,2);
for x = 1:length(shifts)
    
    tmp.shift_seconds = shifts(x);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Shift the sensor data
%     shifted_data = shiftTimeSeries(RAW_DATA, SHIFT);
    
    % Create a copy of the time-series
    tmp.time_series = raw_data;
    
    % Find the non-NaN timestamps
    good_ts = find(~isnan(tmp.time_series(:,1)));
    % Replace duplicate time stamps with nans
    tmp.dups = find(diff(tmp.time_series(good_ts,1)) == 0);
    tmp.time_series(good_ts(tmp.dups+1),:) = NaN;
        
    % Update the return value with the cleaned version of the original
    % time-series
    tmp.shifted_ts = tmp.time_series;
    
    % Add the SHIFT_VALUE to the timestamps of the original time series
    tmp.time_series(:,1) = tmp.time_series(:,1) + tmp.shift_seconds/86400;
    
    % Find all valid rows in the shifted time-series
    tmp.r_shift = find(all(~isnan(tmp.time_series),2));
    % Find all valid rows in the original time-series
    tmp.r_orig = find(all(~isnan(tmp.shifted_ts),2));
    
    % Interpolate to the new time-series
    
    tmp.shifted_ts(tmp.r_orig,2) = interp1(tmp.time_series(tmp.r_shift,1),...
        tmp.time_series(tmp.r_shift,2),...
        tmp.shifted_ts(tmp.r_orig,1));
    tmpgdat=gdat;
    tmpgdat.drv_oxygen=tmp.shifted_ts(:,2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % create interpolated matrix per profile
    % consider the median depth resolution per profile where we have oxygen
    % data
    if strcmp(psetup.deployment.resolution, 'low_res')
        tmp.dbins=ceil(nanmedian(abs(diff(gdat.drv_depth(~isnan(gdat.drv_oxygen))))));
    elseif strcmp(psetup.deployment.resolution, 'high_res')
        tmp.dbins=2;
    end
    GDAT=nocgliders_timeseries_to_Grid2D(tmpgdat, tmp.dbins, {'drv_oxygen','drv_depth','drv_calphase'}, 'drv');
    oxy_profile=nansum(~isnan(GDAT.drv_oxygen));
    GDAT.depth=GDAT.drv_depth;
    GDAT.mtime=GDAT.drv_mtime;
    for i=1:length(gdat.profiles)-1
        if oxy_profile(i)>size(GDAT.depth,1)/2 && oxy_profile(i+1)>size(GDAT.depth,1)/2
            % UPvsDOWN_and_DOWNvsUP
            uMean(:,2)=fillMissingValues(GDAT.drv_oxygen(:,i));
            dMean(:,2)=fillMissingValues(GDAT.drv_oxygen(:,i+1));
            uMean(:,1)=round(fillMissingValues(GDAT.depth(:,i)));
            dMean(:,1)=round(fillMissingValues(GDAT.depth(:,i+1)));

            % Calculate the area between the profiles
            results_UPvsDOWN_and_DOWNvsUP(x,2,i) = profiles2polyArea(dMean, uMean,...
                'plot', false);
            results_UPvsDOWN_and_DOWNvsUP(x,1,i)=shifts(x);

            % UPvsDOWN
            if GDAT.drv_proDir(1,i)==1 
                uMean(:,2)=fillMissingValues(GDAT.drv_oxygen(:,i));
                dMean(:,2)=fillMissingValues(GDAT.drv_oxygen(:,i+1));
                uMean(:,1)=round(fillMissingValues(GDAT.depth(:,i)));
                dMean(:,1)=round(fillMissingValues(GDAT.depth(:,i+1)));
%                 uMean(:,2)=GDAT.drv_oxygen(:,i);
%                 dMean(:,2)=GDAT.drv_oxygen(:,i+1);
%                 uMean(:,1)=GDAT.depth(:,i);
%                 dMean(:,1)=GDAT.depth(:,i+1);

                % Calculate the area between the profiles
                % all depths
                results_UPvsDOWN(x,2,i) = profiles2polyArea(dMean, uMean,...
                    'plot', false);
                results_UPvsDOWN(x,1,i)=shifts(x);

                % upper 500m only
                [~, d]=nanmin(abs(uMean(:,1)-500));
                results_UPvsDOWN_and_DOWNvsUP_500m(x,2,i) = profiles2polyArea(dMean(1:d,:), uMean(1:d,:),...
                    'plot', false);
                results_UPvsDOWN_and_DOWNvsUP_500m(x,1,i)=shifts(x);
            end

                % UPvsDOWN
            if GDAT.drv_proDir(1,i)==-1
                uMean(:,2)=fillMissingValues(GDAT.drv_oxygen(:,i));
                dMean(:,2)=fillMissingValues(GDAT.drv_oxygen(:,i+1));
                uMean(:,1)=round(fillMissingValues(GDAT.depth(:,i)));
                dMean(:,1)=round(fillMissingValues(GDAT.depth(:,i+1)));
%                 uMean(:,2)=GDAT.drv_oxygen(:,i);
%                 dMean(:,2)=GDAT.drv_oxygen(:,i+1);
%                 uMean(:,1)=GDAT.depth(:,i);
%                 dMean(:,1)=GDAT.depth(:,i+1);

                % Calculate the area between the profiles
                results_DOWNvsUP(x,2,i) = profiles2polyArea(dMean, uMean,...
                    'plot', false);
                results_DOWNvsUP(x,1,i)=shifts(x);

                % lower 500m only
                [~, d]=nanmin(abs(uMean(:,1)-500));
                results_UPvsDOWN_and_DOWNvsUP_500m(x,2,i) = profiles2polyArea(dMean(d:end,:), uMean(d:end,:),...
                    'plot', false);
                results_UPvsDOWN_and_DOWNvsUP_500m(x,1,i)=shifts(x);
            end
        end
    end
    
end

for i=1:length(gdat.profiles)-1
    [Y,I] = nanmin(abs(results_UPvsDOWN_and_DOWNvsUP(:,2,i)));
    bestShifts_UPvsDOWN_and_DOWNvsUP(i,1:2) = [shifts(I), Y];

    [Y,I] = nanmin(abs(results_UPvsDOWN(:,2,i)));
    bestShifts_UPvsDOWN(i,1:2) = [shifts(I), Y];

    [Y,I] = nanmin(abs(results_DOWNvsUP(:,2,i)));
    bestShifts_DOWNvsUP(i,1:2) = [shifts(I), Y];

    [Y,I] = nanmin(abs(results_UPvsDOWN_and_DOWNvsUP_500m(:,2,i)));
    bestShifts_UPvsDOWN_and_DOWNvsUP_500m(i,1:2) = [shifts(I), Y];

end
    
    oxygen_lags.UPvsDOWN=bestShifts_UPvsDOWN; % if oxycline is in the top 500 m
    oxygen_lags.DOWNvsUP=bestShifts_DOWNvsUP; % if oxycline is in the bottom 500 m
    oxygen_lags.UPvsDOWN_and_DOWNvsUP=bestShifts_UPvsDOWN_and_DOWNvsUP; % if oxycline is ~ 500 m
    oxygen_lags.UPvsDOWN_and_DOWNvsUP_500m=bestShifts_UPvsDOWN_and_DOWNvsUP_500m; % includes all possible pairings focusing on the top or bottom 500 m closest in time
    
    