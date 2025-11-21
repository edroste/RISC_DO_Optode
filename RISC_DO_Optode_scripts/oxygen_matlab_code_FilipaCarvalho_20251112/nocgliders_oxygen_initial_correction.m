function [gdat, psetup, gsetup]=nocgliders_oxygen_initial_correction(gdat, psetup, gsetup)

    % set input CTD variables and apply a CTD lag (set in gsetup);
    tmp.timestamp_interp=fillMissingValues(gdat.drv_mtime);
    tmp.drv_salinity_shifted=shiftTimeSeries([tmp.timestamp_interp,gdat.drv_salinity],gsetup.processing_options.oxygen.time_lag_CTD);
    tmp.drv_temperature_shifted=shiftTimeSeries([tmp.timestamp_interp,gdat.drv_temperature],gsetup.processing_options.oxygen.time_lag_CTD);
    tmp.drv_pressure_shifted=shiftTimeSeries([tmp.timestamp_interp,gdat.drv_pressure],gsetup.processing_options.oxygen.time_lag_CTD);
    
    % interpolate CTD variables there is CTD data when oxygen is reported
    ctd_vnames = {'drv_salinity_shifted','drv_pressure_shifted','drv_temperature_shifted'};
    for vix = 1:length(ctd_vnames)
        tmp.g = ~isnan(tmp.(ctd_vnames{vix})(:,2)) & ~isnan(tmp.timestamp_interp);
        tmp.([ctd_vnames{vix} '_interp']) = interp1(tmp.timestamp_interp(tmp.g),tmp.(ctd_vnames{vix})(tmp.g,2),tmp.timestamp_interp);
    end
    % if there is a multipoint or 2pt calibration sheet, then apply the CTD
    % lag correction and recalculate oxygen - otherwise, drv_oxygen is what
    % the glider reports (this was set in the extract variables step)
    if gsetup.processing_options.oxygen.optode_calibration_sheet_exists
        % drv_oxygen is 'reported' oxygen recalculated using the multipoint/2pt
        % coefficients and a 4 sec lag in CTD data
        % if there is a multipoint cal available
        tmp.cal_file_mp=[psetup.paths.cal_data 'oxygen/' psetup.deployment.project '_unit' psetup.deployment.glider_ID '_oxy_multical_coeff.mat'];
        tmp.cal_file_2pt=[psetup.paths.cal_data 'oxygen/' psetup.deployment.project '_unit' psetup.deployment.glider_ID '_oxy_2pt_coeff.mat'];
        if ~(isfile(tmp.cal_file_mp) || isfile(tmp.cal_file_2pt))
            if gsetup.processing_options.oxygen.optode_multipoint_cal_exists
                edit([nocgliders_user_path 'matlab_scripts/nocgliders_toolbox/nocgliders_oxygen_coefficients_multipoint_setup.m'])
                
                prompt = 'Have you saved the oxygen coefficients file?';
                choice = menu(prompt,'Yes','No');
                while choice==2
                    disp('Please complete and save the coefficients file using nocgliders_oxygen_coefficients_multipoint_setup.m')
                    edit([nocgliders_user_path 'matlab_scripts/nocgliders_toolbox/nocgliders_oxygen_coefficients_multipoint_setup.m'])
                    prompt = 'Have you saved the oxygen coefficients file?';
                    choice = menu(prompt,'Yes','No');
                end
                

                %,[psetup.paths.cal_data '/oxygen/' psetup.deployment.project_setup_file]);
            end
        end

        if gsetup.processing_options.oxygen.optode_calibration_multipoint_exists && isfile(tmp.cal_file_mp) && isfield(gdat, 'drv_calphase')
            tmp.cal=load(tmp.cal_file_mp);
            gsetup.calibrations.oxygen=tmp.cal.calStruc;
            gsetup.calibrations.oxygen.calibration_filename=[psetup.deployment.project '_unit' psetup.deployment.glider_ID '_oxy_multical_coeff.mat'];
            gsetup.calibrations.oxygen.type='multipoint calibration';
            % drv_oxygen_multipoint is 'reported' oxygen recalculated using the multipoint
            [gdat.drv_oxygen_multipoint, ~,~]=nocgliders_aa_optode_mp_cal(gsetup.calibrations.oxygen, gdat.drv_calphase,tmp.drv_temperature_shifted_interp,tmp.drv_salinity_shifted_interp,tmp.drv_pressure_shifted_interp);
            gdat.drv_oxygen=gdat.drv_oxygen_multipoint; 
        % if there isn't a multipoint cal available
        elseif ~gsetup.processing_options.oxygen.optode_multipoint_cal_exists  && isfile(tmp.cal_file_2pt) && isfield(gdat, 'drv_calphase')
            tmp.cal=load(tmp.cal_file_2pt);
            gsetup.calibrations.oxygen=tmp.cal.calibs;
            gsetup.calibrations.oxygen.calibration_filename=[psetup.deployment.project '_unit' psetup.deployment.glider_ID '_oxy_2pt_coeff.mat'];
            gsetup.calibrations.oxygen.type='2pt calibration';
            % drv_oxygen_2pt is 'reported' oxygen recalculated using the 2pt cal
            [gdat.drv_oxygen_2pt,~, ~] = nocgliders_aa_optode_2pt_cal(gsetup.calibrations.oxygen, gdat.drv_calphase,tmp.drv_temperature_shifted_interp,tmp.drv_salinity_shifted_interp,tmp.drv_pressure_shifted_interp);
            gdat.drv_oxygen=gdat.drv_oxygen_2pt;
        end
    end