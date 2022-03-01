clear all;

load("/Users/fer003/uibgitlab/stipendiat/GRB/Andrew_data/clean_BGO7_CZT1.mat");
% FOR SPECTRA
% BGO
tB = D.tus(D.BGO) + D.ttk(D.BGO)/36;
ergB = D.erg(D.BGO);
dauB = D.dau(D.BGO);
detB = D.det(D.BGO);
typB = D.typ(D.BGO);

% CZT
%ind = D.CZT & D.mlh==0 & D.erg>160 & D.erg<850;  % here form the indices of correct pixels
%ind = D.CZT & D.mlh==0;  % here form the indices of correct pixels

ind = D.CZT %& D.erg>150 & D.erg<850;  % here form the indices of correct pixels

ADD = D.dau(ind)*32 + D.add(ind);
[~, ~, pixel_energy] = czt_make_spectra_per_pixel(ADD, D.chn(ind), D.erg(ind));
%[~, ~, pixel_energy] = czt_make_spectra_per_pixel(D.add(D.CZT), D.chn(D.CZT), D.erg(D.CZT)); % WRONG

tC = D.tus(ind);

keVC = pixel_energy;
%tim = D.tim;
%mlhC = D.mlh;
mlhC = D.mlh(ind);

save("/Users/fer003/uibgitlab/stipendiat/GRB/Andrew_data/clean_BGO7_CZT1_python_v2.mat", "dauB", "detB", "ergB", "tB", "typB", "tC", "keVC", "mlhC")