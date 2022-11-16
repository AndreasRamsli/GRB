clear all
close all
clc

% YEAR MONTH DAY HOUR MINUTE SECOND
WANTED_DATETIME = datetime(2019,3,5,13,3,48);
TIME_WINDOW_IN_MINUTES = 2;

cd(fileparts(which(mfilename)));
disp(pwd);
addpath ./NASA_CDF_PATCH/
HomeDir = '/Home/siv30/wad005/master/GRB/MATLAB/david_sarria';
TargetDir = '/scratch/ASDC/net/felles3.uib.no/vol/ift_asdc/bulktransfer2/ops/MXGS/cdf/';
rootdir = TargetDir;

my_year = year(WANTED_DATETIME);
my_doy = day(WANTED_DATETIME,'dayofyear');

%%

disp(['Processing DOY ' num2str(my_doy) ' ...'])
out_data = get_trigger_accumulated_background_data(my_doy,my_year,rootdir, WANTED_DATETIME, TIME_WINDOW_IN_MINUTES);

disp(num2str(length(out_data)));
out_data = unique(out_data,'rows');
disp(num2str(length(out_data)));

out_filename = [num2str(year(WANTED_DATETIME)) '_' num2str(month(WANTED_DATETIME)) '_' num2str(day(WANTED_DATETIME)) '_'...
    num2str(hour(WANTED_DATETIME)) '_' num2str(minute(WANTED_DATETIME)) '_' num2str(round(second(WANTED_DATETIME)))...
    '.mat'];

save(out_filename,'out_data')




%%
function mat_out = get_trigger_accumulated_background_data(myDOY, year, rootdir, WANTED_DATETIME, TIME_WINDOW_IN_MINUTES)

mat_out=[];

% make file list for selected DOYs
files = {};


files_dir = {};
pref = [rootdir 'mxgstgfobservationlevel1/' num2str(year)];
%     end
path = [pref, filesep, num2str(myDOY, '%03.f'), filesep];
fs = dir(path);

for i = 1:numel(fs) - 2
    files_dir(i) = {[path, fs(i + 2).name]};
end

files = [files files_dir];


nb_files = size(files, 2);

if nb_files==0
   error('No data file for selected date, must be a mistake somewhere.') 
end

% nb_failed = 0;
% nb_sucess = 0;

for i_file = 1:nb_files % can be for or parfor
    
    fprintf('\nFile %s(%s) \n', num2str(i_file), num2str(size(files, 2)));
    
    if (size(files, 2) > 1) && (~ischar(files))
        filename = files{i_file};
    else
        filename = files;
    end
    
    [mat_out_tmp] = spectra_from_triggers_v8(filename, WANTED_DATETIME, TIME_WINDOW_IN_MINUTES);
    
    if ~isempty(mat_out_tmp)
        mat_out = [mat_out ; mat_out_tmp];
    end
    
end

end
