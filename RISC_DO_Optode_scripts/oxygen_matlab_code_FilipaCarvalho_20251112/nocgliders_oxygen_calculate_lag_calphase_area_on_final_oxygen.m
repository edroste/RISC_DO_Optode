function oxygen_lags=nocgliders_oxygen_calculate_lag_calphase_area_on_final_oxygen(gdat, psetup, calphase_shifts, temperature_shifts, calStruc)
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
pathname=psetup.pathname;
mtime='drv_mtime';
sensor='drv_calphase';
raw_data=[gdat.(mtime), gdat.(sensor)];

clear tmp.shifted_ts results uMean dMean
results_UPvsDOWN_and_DOWNvsUP=nan(length(calphase_shifts),2,length(gdat.profiles)-1);
bestShifts_UPvsDOWN_and_DOWNvsUP=nan(length(gdat.profiles)-1,2);
results_UPvsDOWN=nan(length(calphase_shifts),2,length(gdat.profiles)-1);
bestShifts_UPvsDOWN=nan(length(gdat.profiles)-1,2);
results_DOWNvsUP=nan(length(calphase_shifts),2,length(gdat.profiles)-1);
bestShifts_DOWNvsUP=nan(length(gdat.profiles)-1,2);
results_UPvsDOWN_and_DOWNvsUP_500m=nan(length(calphase_shifts),2,length(gdat.profiles)-1);
bestShifts_UPvsDOWN_and_DOWNvsUP_500m=nan(length(gdat.profiles)-1,2);

% figure(100); subplot(1,2,1)
% aa=~isnan(gdat.drv_temperature+gdat.drv_pressure) & gdat.drv_proIDs==250;
% p=plot(gdat.drv_temperature_in_situ(aa), gdat.drv_pressure(aa), 'k-', 'linewidth', 2); hold on;
% aa=~isnan(gdat.drv_temperature+gdat.drv_pressure) & gdat.drv_proIDs==251;
% plot(gdat.drv_temperature_in_situ(aa), gdat.drv_pressure(aa), ':', 'color', 'k', 'linewidth', 2); 
% subplot(1,2,2)
% aa=~isnan(gdat.drv_salinity+gdat.drv_pressure) & gdat.drv_proIDs==250;
% p=plot(gdat.drv_salinity_practical(aa), gdat.drv_pressure(aa), 'k-', 'linewidth', 2); hold on;
% aa=~isnan(gdat.drv_salinity+gdat.drv_pressure) & gdat.drv_proIDs==251;
% plot(gdat.drv_salinity_practical(aa), gdat.drv_pressure(aa), ':', 'color', 'k', 'linewidth', 2); 
% ti=0;

for t=1:length(temperature_shifts)
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tshift=temperature_shifts(t)
    tmp.shift_seconds = temperature_shifts(t);
    % Shift the temperature data
%     shifted_data = shiftTimeSeries(RAW_DATA, SHIFT);

    % Create a copy of the time-series
    tmp.time_series = [gdat.(mtime), gdat.drv_temperature_in_situ];

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
    tmpgdat=gdat;

    tmp.shifted_ts(tmp.r_orig,2) = interp1(tmp.time_series(tmp.r_shift,1),...
        tmp.time_series(tmp.r_shift,2),...
        tmp.shifted_ts(tmp.r_orig,1)); 
    
    tmpgdat.drv_temperature_shifted=tmp.shifted_ts(:,2);
    tmpgdat.drv_temperature=tmpgdat.drv_temperature_shifted;
    
% shift salinity data
    tmp.shift_seconds = temperature_shifts(t)+0;

    % Create a copy of the time-series
    tmp.time_series = [gdat.(mtime), gdat.drv_conductivity];

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
    tmpgdat.drv_cond_shifted=tmp.shifted_ts(:,2);
    tmpgdat.drv_cond=tmpgdat.drv_cond_shifted;
    tmpgdat.drv_salinity=gsw_SP_from_C(tmpgdat.drv_cond_shifted*10,tmpgdat.drv_temperature, gdat.drv_pressure);

    
%     figure(100); subplot(1,2,1)
% %     plot(tmpgdat.drv_temperature, tmpgdat.drv_pressure, '-'); hold on;
%     aa=~isnan(tmpgdat.drv_temperature+gdat.drv_pressure) & gdat.drv_proIDs==250;
%     p=plot(tmpgdat.drv_temperature(aa), gdat.drv_pressure(aa), '-', 'linewidth', 2); hold on
%     a=p.Color;
%     aa=~isnan(tmpgdat.drv_temperature+gdat.drv_pressure) & gdat.drv_proIDs==251;
%     plot(tmpgdat.drv_temperature(aa), gdat.drv_pressure(aa), ':', 'color', a, 'linewidth', 2); 
%     
% %     tmpgdat.drv_salinity=gsw_SP_from_C(gdat.drv_conductivity*10,tmpgdat.drv_temperature, gdat.drv_pressure);
%     figure(100); subplot(1,2,2)
% %     plot(tmpgdat.drv_salinity, tmpgdat.drv_pressure, '-', 'color', a); hold on;
%     aa=~isnan(tmpgdat.drv_salinity+gdat.drv_pressure) & gdat.drv_proIDs==250;
%     plot(tmpgdat.drv_salinity(aa), gdat.drv_pressure(aa), '-', 'linewidth', 2, 'color', a); hold on
% %     a=p.Color;
%     aa=~isnan(tmpgdat.drv_salinity+gdat.drv_pressure) & gdat.drv_proIDs==251;
%     plot(tmpgdat.drv_salinity(aa), gdat.drv_pressure(aa), ':', 'color', a, 'linewidth', 2, 'color', a); 
%     ti=[ti;tshift];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for x = 1:length(calphase_shifts)
        clear tmp
        tmp.shift_seconds = calphase_shifts(x);
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
        tmpgdat.drv_calphase_shifted=tmp.shifted_ts(:,2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % create interpolated matrix per profile
        % consider the median depth resolution per profile where we have oxygen
        % data
        if strcmp(psetup.deployment.resolution, 'low_res')
            tmp.dbins=ceil(nanmedian(abs(diff(gdat.drv_depth(~isnan(gdat.drv_calphase_shifted))))));
        elseif strcmp(psetup.deployment.resolution, 'high_res')
            tmp.dbins=2;
        end
    %     GDAT=nocgliders_timeseries_to_Grid2D(tmpgdat, tmp.dbins, {'drv_temperature','drv_pressure','drv_salinity', 'drv_calphase_shifted'}, 'drv');
    %     for i=1:length(gdat.profiles)
    %         i
    %         [O2,O2eq,O2sat]=aa_optode_mp(calStruc, GDAT.drv_calphase_shifted(:,i),GDAT.drv_temperature(:,i),GDAT.drv_salinity(:,i),GDAT.drv_pressure(:,i));
    %         gdat.drv_oxygen_multipoint(:,i)=O2;
    %     end
            ctd_vnames = {'drv_salinity','drv_pressure_sci','drv_temperature', 'drv_proIDs'};
            tmp.timestamp_interp=fillMissingValues(gdat.drv_mtime_sci);
            for vix = 1:length(ctd_vnames)
                vname = ctd_vnames{vix};
                g = ~isnan(gdat.(vname)) & ~isnan(tmp.timestamp_interp);
                tmp.([vname '_interp']) = interp1(tmp.timestamp_interp(g),tmpgdat.(vname)(g),tmp.timestamp_interp);
            end

        [tmpgdat.drv_oxygen_shifted, gdat.drv_oxygen_eq, ~]=aa_optode_mp(calStruc, tmpgdat.drv_calphase_shifted,tmp.drv_temperature_interp,tmp.drv_salinity_interp,tmp.drv_pressure_sci_interp);

        GDAT=nocgliders_timeseries_to_Grid2D(tmpgdat, tmp.dbins, {'drv_oxygen_shifted','drv_pressure','drv_calphase'}, 'drv');
        oxy_profile=nansum(~isnan(GDAT.drv_oxygen_shifted));
        GDAT.pressure=GDAT.drv_pressure;
        GDAT.mtime=GDAT.drv_mtime;

        for i=1:length(gdat.profiles)-1
            if oxy_profile(i)>size(GDAT.pressure,1)/2 && oxy_profile(i+1)>size(GDAT.pressure,1)/2
                % UPvsDOWN_and_DOWNvsUP
                uMean(:,2)=fillMissingValues(GDAT.drv_oxygen_shifted(:,i));
                dMean(:,2)=fillMissingValues(GDAT.drv_oxygen_shifted(:,i+1));
                uMean(:,1)=round(fillMissingValues(GDAT.pressure(:,i)));
                dMean(:,1)=round(fillMissingValues(GDAT.pressure(:,i+1)));

                % Calculate the area between the profiles
                results_UPvsDOWN_and_DOWNvsUP(x,2,i) = profiles2polyArea(dMean, uMean,...
                        'plot', true); 
                hold on
                plot(uMean(:,2), uMean(:,1), 'r-')
                plot(dMean(:,2), dMean(:,1), 'b-')
                set(gcf, 'PaperPositionMode', 'auto')
                print('-dpng', '-r50', [pathname 'figure_profile_' num2str(i)  '_UPvsDOWN_and_DOWNvsUP_' 'calphase_shift_' num2str(tmp.shift_seconds)  'temp_shift_' num2str(tshift) 's.png']);
                close all
                results_UPvsDOWN_and_DOWNvsUP(x,1,i)=calphase_shifts(x);

                % UPvsDOWN
                if GDAT.drv_proDir(1,i)==1 
                    uMean(:,2)=fillMissingValues(GDAT.drv_oxygen_shifted(:,i));
                    dMean(:,2)=fillMissingValues(GDAT.drv_oxygen_shifted(:,i+1));
                    uMean(:,1)=round(fillMissingValues(GDAT.pressure(:,i)));
                    dMean(:,1)=round(fillMissingValues(GDAT.pressure(:,i+1)));
    %                 uMean(:,2)=GDAT.drv_oxygen_shifted(:,i);
    %                 dMean(:,2)=GDAT.drv_oxygen_shifted(:,i+1);
    %                 uMean(:,1)=GDAT.pressure(:,i);
    %                 dMean(:,1)=GDAT.pressure(:,i+1);

                    % Calculate the area between the profiles
                    % all depths
                    results_UPvsDOWN(x,2,i) = profiles2polyArea(dMean, uMean,...
                        'plot', true);
                    hold on
                    plot(uMean(:,2), uMean(:,1), 'r-')
                    plot(dMean(:,2), dMean(:,1), 'b-')
                    set(gcf, 'PaperPositionMode', 'auto')
                    print('-dpng', '-r50', [pathname 'figure_profile_' num2str(i)  '_UPvsDOWN_' 'calphase_shift_' num2str(tmp.shift_seconds)  'temp_shift_' num2str(tshift) 's.png']);
                    results_UPvsDOWN(x,1,i)=calphase_shifts(x);
                    close all

                    % upper 500m only
                    [~, d]=nanmin(abs(uMean(:,1)-500));
                    results_UPvsDOWN_and_DOWNvsUP_500m(x,2,i) = profiles2polyArea(dMean(1:d,:), uMean(1:d,:),...
                        'plot', true);
                    hold on
                    plot(uMean(:,2), uMean(:,1), 'r-')
                    plot(dMean(:,2), dMean(:,1), 'b-')
                    set(gcf, 'PaperPositionMode', 'auto')
                    print('-dpng', '-r50', [pathname 'figure_profile_' num2str(i)  '_UPvsDOWN_and_DOWNvsUP_500m_' 'calphase_shift_' num2str(tmp.shift_seconds)  'temp_shift_' num2str(tshift) 's.png']);
                    close all
                    results_UPvsDOWN_and_DOWNvsUP_500m(x,1,i)=calphase_shifts(x);
                end

                    % UPvsDOWN
                if GDAT.drv_proDir(1,i)==-1
                    uMean(:,2)=fillMissingValues(GDAT.drv_oxygen_shifted(:,i));
                    dMean(:,2)=fillMissingValues(GDAT.drv_oxygen_shifted(:,i+1));
                    uMean(:,1)=round(fillMissingValues(GDAT.pressure(:,i)));
                    dMean(:,1)=round(fillMissingValues(GDAT.pressure(:,i+1)));
    %                 uMean(:,2)=GDAT.drv_oxygen_shifted(:,i);
    %                 dMean(:,2)=GDAT.drv_oxygen_shifted(:,i+1);
    %                 uMean(:,1)=GDAT.pressure(:,i);
    %                 dMean(:,1)=GDAT.pressure(:,i+1);

                    % Calculate the area between the profiles
                    results_DOWNvsUP(x,2,i) = profiles2polyArea(dMean, uMean,...
                        'plot', true);
                    hold on
                    plot(uMean(:,2), uMean(:,1), 'r-')
                    plot(dMean(:,2), dMean(:,1), 'b-')
                    set(gcf, 'PaperPositionMode', 'auto')
                    print('-dpng', '-r50', [pathname 'figure_profile_' num2str(i)  '_DOWNvsUP_' 'calphase_shift_' num2str(tmp.shift_seconds)  'temp_shift_' num2str(tshift) 's.png']);
                    results_DOWNvsUP(x,1,i)=calphase_shifts(x);
                    close all

                    % lower 500m only
                    [~, d]=nanmin(abs(uMean(:,1)-500));
                    results_UPvsDOWN_and_DOWNvsUP_500m(x,2,i) = profiles2polyArea(dMean(d:end,:), uMean(d:end,:),...
                        'plot', true);
                    hold on
                    plot(uMean(:,2), uMean(:,1), 'r-')
                    plot(dMean(:,2), dMean(:,1), 'b-')
                    set(gcf, 'PaperPositionMode', 'auto')
                    print('-dpng', '-r50', [pathname 'figure_profile_' num2str(i)  '_UPvsDOWN_and_DOWNvsUP_500m_' 'calphase_shift_' num2str(tmp.shift_seconds)  'temp_shift_' num2str(tshift) 's.png']);
                    results_UPvsDOWN_and_DOWNvsUP_500m(x,1,i)=calphase_shifts(x);
                    close all
                end
            end
        end

    end
end

for i=1:length(gdat.profiles)-1
    [Y,I] = nanmin(abs(results_UPvsDOWN_and_DOWNvsUP(:,2,i)));
    bestShifts_UPvsDOWN_and_DOWNvsUP(i,1:2) = [calphase_shifts(I), Y];

    [Y,I] = nanmin(abs(results_UPvsDOWN(:,2,i)));
    bestShifts_UPvsDOWN(i,1:2) = [calphase_shifts(I), Y];

    [Y,I] = nanmin(abs(results_DOWNvsUP(:,2,i)));
    bestShifts_DOWNvsUP(i,1:2) = [calphase_shifts(I), Y];

    [Y,I] = nanmin(abs(results_UPvsDOWN_and_DOWNvsUP_500m(:,2,i)));
    bestShifts_UPvsDOWN_and_DOWNvsUP_500m(i,1:2) = [calphase_shifts(I), Y];

end
    oxygen_lags.results.results_UPvsDOWN_and_DOWNvsUP=results_UPvsDOWN_and_DOWNvsUP;
    oxygen_lags.results.results_UPvsDOWN=results_UPvsDOWN;
    oxygen_lags.results.results_DOWNvsUP=results_DOWNvsUP;
    oxygen_lags.results.results_UPvsDOWN_and_DOWNvsUP_500m=results_UPvsDOWN_and_DOWNvsUP_500m;

    
    oxygen_lags.UPvsDOWN=bestShifts_UPvsDOWN; % if oxycline is in the top 500 m
    oxygen_lags.DOWNvsUP=bestShifts_DOWNvsUP; % if oxycline is in the bottom 500 m
    oxygen_lags.UPvsDOWN_and_DOWNvsUP=bestShifts_UPvsDOWN_and_DOWNvsUP; % if oxycline is ~ 500 m
    oxygen_lags.UPvsDOWN_and_DOWNvsUP_500m=bestShifts_UPvsDOWN_and_DOWNvsUP_500m; % includes all possible pairings focusing on the top or bottom 500 m closest in time
    
%     oxygen_lags.ti=ti;
