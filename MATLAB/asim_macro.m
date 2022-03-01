clear all;
%close all;

[lat, lon, t0, tsc, tms, tus, ttk, typ, erg, dau, det] = DataReadOrder(2018,356,21,4); % 2019-Sep-03 18:51:57.085569

binsize = 10000; % 10 us

ff = PlotBGO(t0, tsc, tms, tus, ttk, typ, erg, dau, det, binsize, lat, lon);
