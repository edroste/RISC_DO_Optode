% this creates a new multipoint calibration file
calStruc.project=psetup.deployment.project;
calStruc.region=psetup.deployment.region;
calStruc.gliderID=psetup.deployment.glider_ID;
% using the data on the calibration sheet, copy the  values to fill this
% example structure
% calStruc.SN=122;
% calStruc.mtime_cal=datetime(2020,10,04);
% calStruc.Certificate='4831_122_00177388';
% calStruc.Product='4831';
% calStruc.foi_batch='1206EM';
% calStruc.ConcCoef = [0.00000E00 1.00000E00];
% calStruc.PhaseCoef = [0.00000E00 1.00000E00 0.00000E00 0.00000E00];
% calStruc.salinity=0;
% calStruc.SVU=[2.58424E-03; 1.08395E-04; 2.19239E-06; 1.88605E02; -2.94489E-01; -4.59519E01; 3.73597E00];
% % BIO-Carbon 405
% calStruc.SN=143;
% calStruc.mtime_cal= datetime(2020,11,6); %datetime(yy,mm,dd);
% calStruc.Certificate= '4831_143_00178652'; % string
% calStruc.Product= '4831'; % string
% calStruc.foi_batch= '1206EM'; % string
% calStruc.ConcCoef = [0e0 1e0];
% calStruc.PhaseCoef = [0e0 1e0 0e0 0e0];
% calStruc.salinity=0;
% calStruc.SVU=[2.69734e-03; 1.12438e-04; 2.35904e-06;1.81897e02; -2.28490e-01; -4.65458e01; 3.57694e00];
% 


calStruc.SN=nan;
calStruc.mtime_cal= datetime(nan,nan,nan); %datetime(yy,mm,dd);
calStruc.Certificate= nan; % string
calStruc.Product= nan; % string
calStruc.foi_batch= nan; % string
calStruc.ConcCoef = [nan nan];
calStruc.PhaseCoef = [nan nan nan nan];
calStruc.salinity=nan;
calStruc.SVU=[nan; nan; nan;nan; nan; nan; nan];
save([char(psetup.paths.cal_data) 'oxygen/' char(psetup.deployment.project) '_unit' char(psetup.deployment.glider_ID) '_oxy_multical_coeff.mat'], 'calStruc');
% save([psetup.paths.cal_data '/oxygen/' psetup.deployment.project '_unit' psetup.deployment.glider_ID '_oxy_multical_coeff.mat'], 'calStruc');
clear calStruc

if isfile([char(psetup.paths.cal_data) 'oxygen/' char(psetup.deployment.project) '_unit' char(psetup.deployment.glider_ID) '_oxy_multical_coeff.mat'])
    disp('## Your multipoint calibration coefficients file has been saved!')
end

