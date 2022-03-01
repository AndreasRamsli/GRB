function ff = PlotBGO(T0, tsc, tms, tus, ttk, typ, erg, dau, det, BinSize, lat, lon);

leap = -18;   % leap seconds

DetCol = [[0, 0, 1]; [0, 0.75, 1]; [0.5, 0.75, 1];...      % DAU1, bluish
          [0, 1, 0]; [0.5, 1, 0.75]; [0.75, 1, 0.5];...    % DAU2, greenish
          [1, 0, 0]; [1, 0.5, 0]; [0.64, 0.08, 0.18];...   % DAU3, reddish
          [0.5, 0.2, 0.5]; [1, 0, 1]; [1, 0.7, 1]];        % DAU4, purplish

adr = (dau-1)*3 + det;        % converts dau-det into detector number in range of [1:12]

[~, I] = sort(36*double(tus) + double(ttk));  % time sorting including 36 MHz ticks
tus = tus(I); ttk = ttk(I); typ = typ(I); erg = erg(I); adr = adr(I); dau = dau(I); det = det(I);

%I = typ<3;                    % reject VALs
%tus = tus(I); ttk = ttk(I); typ = typ(I); erg = erg(I); adr = adr(I);

tus = double(tus) + double(ttk)/36;   % time with sub-us precision

erg(typ==2) = erg(typ==2) + 3000;

ff = figure(2); clf, box on 
set(gcf, 'renderer', 'Painters'); % for EPS

ax(1) = subplot(2, 1, 1); hold on, box on, grid on

plot(tus, erg, '.', 'MarkerSize', 2)  % plot all counts
% plot(tus(SC), erg(SC), 'k.', 'MarkerSize', 24)  % plot all AC/SC

for d = 1:12
    plot(tus(adr==d), erg(adr==d), '.', 'Color', DetCol(d, :), 'MarkerSize', 20) % color diff dets
end

plot(tus(typ==1), erg(typ==1), 'y.', 'MarkerSize', 10)  % highlight FST

plot(tus(typ==2), erg(typ==2), 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 3)  % highlight OVF

xlabel('time, \mus') 
ylabel('energy channel #')


T = T0 + seconds(double(tsc + leap) + double(tms)*1e-3);  % time reference
T.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
date = char(T);
title({char(T); ['Produced: ',char(datetime)]});

if sum(typ==2)>0
    legend(' ', 'DAU1 -> DET1', 'DAU1 -> DET2', 'DAU1 -> DET3',...
                                 'DAU2 -> DET1', 'DAU2 -> DET2', 'DAU2 -> DET3',...
                                 'DAU3 -> DET1', 'DAU3 -> DET2', 'DAU3 -> DET3',...
                                 'DAU4 -> DET1', 'DAU4 -> DET2', 'DAU4 -> DET3',...
                                 'FST counts', 'OVF counts');
else
    legend(' ', 'DAU1 -> DET1', 'DAU1 -> DET2', 'DAU1 -> DET3',...
                                 'DAU2 -> DET1', 'DAU2 -> DET2', 'DAU2 -> DET3',...
                                 'DAU3 -> DET1', 'DAU3 -> DET2', 'DAU3 -> DET3',...
                                 'DAU4 -> DET1', 'DAU4 -> DET2', 'DAU4 -> DET3',...
                                 'FST counts');
end


edgT = [-1e6:BinSize:2e6];
tusC = histc(tus, edgT); 

ax(2) = subplot(2, 1, 2); hold on, box on, grid on
bar(edgT, tusC, 'histc')    % lightcurve
xlabel('time, \mus') 
ylabel(['counts in ' num2str(BinSize) ' \mus'])

linkaxes(ax, 'x')           % link time axes of both subplots to each other
set(gca, 'xlim', [0, 1e6])  % set up certain time window

string = datestr(T, 'yyyy_mm_dd_HH_MM_SS');
filename =  ['output/file_mat_TGF/',char(string), '.mat'];
save(filename, 'date', 'dau', 'det', 'erg', 'lat', 'lon', 'tms', 'tsc', 'tus', 'typ', 'DetCol', 'adr', '-v7');
end
