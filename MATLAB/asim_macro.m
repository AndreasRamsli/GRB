clear all;
close all;

[lat, lon, t0, tsc, tms, tus, ttk, typ, erg, dau, det] = DataReadOrder(2020,362,24,1); % Format: 2019-Sep-03 18:51:57.085569


%Data = DataReadBin(2018, 172, 16, 2);


binsize = 10000; % 10 us

ff = PlotBGO(t0, tsc, tms, tus, ttk, typ, erg, dau, det, binsize, lat, lon);

%PlotData(Data, binsize);


%string = datestr(T, 'yyyy_mm_dd_HH_MM_SS');
%filename =  ['/Users/fer003/Dropbox/Stipendiat/MATLAB/ASIM lectures/ASIM_python/',char(string), '.mat'];
%save(filename, 'date', 'dau', 'det', 'erg', 'lat', 'lon', 'tms', 'tsc', 'ttk', 'tus', 'typ', 'DetCol', 'adr', '-v7');
