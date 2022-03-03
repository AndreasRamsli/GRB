function [Lat, Lon, T0, Tsc, Tms, Tus, Ttk, Typ, Erg, Dau, Det] = DataReadOrder(year, DOY, varargin);

% [lat, lon, t0, tsc, tms, tus, ttk, typ, erg, dau, det] = DataReadOrder(year, DOY, F_num, Tr_num);
% [Lat, Lon, T0, Tsc, Tms, Tus, Ttk, Typ, Erg, Dau, Det] = DataReadOrder(year, DOY, F_num);
% This function makes ML data for the whole day BGO data. 
%
% Specify your path to cdg364 patch (line 11)
% and your path to the data (line 14).

%---------------------
addpath ('matlab_cdf370_patch-64');
%---------------------
%DataDir = '/Volumes/ift_asdc/bulktransfer/ops/MXGS/cdf/mxgstgfobservation/';    %% uncomment here <-------------------
%DataDir = '/Volumes/Helheim/Data/ASIM/MXGS/cdf/mxgstgfobservation/';    %% uncomment here <-------------------
DataDir = '/Volumes/ift_asdc/bulktransfer2/ops/MXGS/cdf/mxgstgfobservation/';    %% uncomment here <-------------------

T0 = datetime(datevec(datenum(year, 1, 1, 0, 0, 0)));

Lat = []; Lon = []; Tsc = []; Tms = []; Tus = []; Ttk = []; Typ = []; Erg = []; Dau = []; Det = [];
DOY_Path = [DataDir int2str(year) '/' sprintf('%03d', DOY) '/'];
K = varargin{1};
try
    list = dir([DOY_Path, '*cdf']); % list of cdf files in DOY folder
    fn = [DOY_Path  list(K).name];
catch
    disp('Something is wrong with data path. Check YEAR, DOY and file number.')
    return
end

[Lat, Lon, Tsc, Tms, Tus, Ttk, Typ, Erg, Dau, Det] = MakeData(fn);

if length(varargin)==2
    try
        k = varargin{2};
        Lat = Lat(k); Lon = Lon(k);
        Tsc = Tsc(k); Tms = Tms(k);
        Tus = Tus(k).val; Ttk = Ttk(k).val;
        Typ = Typ(k).val; Erg = Erg(k).val;
        Dau = Dau(k).val; Det = Det(k).val;
    catch
        disp('Something is wrong with required trigger number.')
        disp(['Total number of triggers is ' int2str(length(Tus)) '.'])
    end
end


%**************************************************************************
function [Lat, Lon, Tsc, Tms, Tus, Ttk, Typ, Erg, Dau, Det] = MakeData(fn);

Tus = struct; Ttk = struct; Typ = struct; Erg = struct; Dau = struct; Det = struct; 

[data, info] = spdfcdfread(fn);  % read data and data info; this function closes the file itself
names = info.Variables(:, 1);    % list of all variables names

[s, ms, PreDAU] = GetVariables(data, names, 'utc_seconds', 'utc_msec', 'dpu_count_prereset');
s = double(s); ms = double(ms); PreDAU = int32(PreDAU);

[Lat, Lon, ordN, adrN, TusN, TtkN, ErgN, ordF, adrF, TusF, TtkF, ErgF, ordV, adrV, TusV, TtkV, ErgV,...
           ordO, adrO, TusO, TtkO, ErgO] = GetVariables(data, names, 'latitude', 'longitude',...
    'bgo_normal_order', 'bgo_normal_address', 'bgo_normal_timestamp', ...
    'bgo_normal_fast_stamp', 'bgo_normal_pulse_height', ...
    'bgo_fast_peak_order', 'bgo_fast_peak_address', 'bgo_fast_peak_timestamp', ...
    'bgo_fast_peak_fast_stamp', 'bgo_fast_peak_pulse_height', ...
    'bgo_fast_valley_order', 'bgo_fast_valley_address', 'bgo_fast_valley_timestamp', ...
    'bgo_fast_valley_fast_stamp', 'bgo_fast_valley_pulse_height',...
    'bgo_overflow_order', 'bgo_overflow_address', 'bgo_overflow_timestamp', ...
    'bgo_overflow_fast_stamp', 'bgo_overflow_overflow_duration');  

if ischar(ordN)
    ordN = []; adrN = []; TusN = []; TtkN = []; ErgN = [];
end
if ischar(ordF)
    ordF = []; adrF = []; TusF = []; TtkF = []; ErgF = [];
end
if ischar(ordV)
    ordV = []; adrV = []; TusV = []; TtkV = []; ErgV = [];
end
if ischar(ordO)
    ordO = []; adrO = []; TusO = []; TtkO = []; ErgO = [];
end

Tsc = s; Tms = ms;

[Tus, Ttk, Typ, Erg, Dau, Det] = Parse_Data(Tus, Ttk, Typ, Erg, Dau, Det, s, PreDAU,... 
    ordN, adrN, TusN, TtkN, ErgN, ordF, adrF, TusF, TtkF, ErgF, ordV, adrV, TusV, TtkV, ErgV, ordO, adrO, TusO, TtkO, ErgO);  
%**************************************************************************

%**************************************************************************
function [Tus, Ttk, Typ, Erg, Dau, Det] = Parse_Data(Tus, Ttk, Typ, Erg, Dau, Det, s, PreDAU,... 
          OrdN, AdrN, TusN, TtkN, ErgN, OrdF, AdrF, TusF, TtkF, ErgF, OrdV, AdrV, TusV, TtkV, ErgV, OrdO, AdrO, TusO, TtkO, ErgO);   

for k = 1:length(s)
    if not(isempty(OrdN))
        good = TusN(k, :)<1e9; 
        tusN = TusN(k, good).'; ttkN = TtkN(k, good).'; ergN = ErgN(k, good).'; adrN = AdrN(k, good).'; ordN = OrdN(k, good).';
    else
        tusN = []; ttkN = []; ergN = []; adrN = []; ordN = [];
    end
        
    if not(isempty(OrdF))
        good = TusF(k, :)<1e9; 
        tusF = TusF(k, good).'; ttkF = TtkF(k, good).'; ergF = ErgF(k, good).'; adrF = AdrF(k, good).'; ordF = OrdF(k, good).';
    else
        tusF = []; ttkF = []; ergF = []; adrF = []; ordF = [];
    end
    
    if not(isempty(OrdV))
        good = TusV(k, :)<1e9;
        tusV = TusV(k, good).'; ttkV = TtkV(k, good).'; ergV = ErgV(k, good).'; adrV = AdrV(k, good).'; ordV = OrdV(k, good).';
    else
        tusV = []; ttkV = []; ergV = []; adrV = []; ordV = [];
    end
    
    if not(isempty(OrdO))
        good = TusO(k, :)<1e9;
        tusO = TusO(k, good).'; ttkO = TtkO(k, good).'; ergO = ErgO(k, good).'; adrO = AdrO(k, good).'; ordO = OrdO(k, good).';
    else
        tusO = []; ttkO = []; ergO = []; adrO = []; ordO = [];
    end
    
    ord = [ordN; ordF; ordV; ordO]; % order for all types within the trigger
    
%     plot(diff(sort(double(ord))), '.-'), grid on  % check for missing counts
%     sum(diff(sort(double(ord)))~=1)  % check for missing counts

    tus = [tusN; tusF; tusV; tusO]; 
    ttk = [ttkN; ttkF; ttkV; ttkO]; 
    erg = [ergN; ergF; ergV; ergO]; 
    adr = [adrN; adrF; adrV; adrO] + 1; % adr starts from 0; increase by 1 
    typ = [zeros(size(ordN)); ones(size(ordF)); 3*ones(size(ordV)); 2*ones(size(ordO))];  % construct typ
    det = rem(adr, 4);
    dau = ((adr - det) / 4) + 1;
    
    % sort events by order
    [~, I] = sort(ord);  
    tus = int32(tus(I));   % scrambled saw || int32 --> can operate with negatives
    ttk = ttk(I); typ = typ(I); erg = erg(I); dau = dau(I); det = det(I);
    Tus(k).val0 = tus; Ttk(k).val0 = ttk; Typ(k).val0 = typ; Erg(k).val0 = erg; Dau(k).val0 = dau; Det(k).val0 = det;
    %---------------------
    
    % correct seconds for second boundaries
    % unscramble saw
    Utus = tus;            % scrambled stairs-2e6
    dt = diff(Utus);  
    T_jump = 6e5;          % this works with uncorrupted data; for corrupted data result is crap
    ind_down = find(dt<-T_jump); 
    for j = 1:length(ind_down)
        Utus(ind_down(j)+1:end) = Utus(ind_down(j)+1:end) + 2e6;
    end
    ind_up = find(dt>T_jump); 
    for j = 1:length(ind_up)
        Utus(ind_up(j)+1:end) = Utus(ind_up(j)+1:end) - 2e6;
    end
    [~, I] = sort(Utus);   % sort stairs-2e6 by time --> unscramble it
    tus = tus(I);          % unscrambled saw
    ttk = ttk(I); typ = typ(I); erg = erg(I); dau = dau(I); det = det(I); % unscramble everything, sort by time
    
    % remove steps from stairs
    dt = diff(tus);  
    ind_down = find(dt<-T_jump); 
    for j = 1:length(ind_down)
        if j==1
            tus(ind_down(j)+1:end) = tus(ind_down(j)+1:end) + PreDAU(k);
        else
            tus(ind_down(j)+1:end) = tus(ind_down(j)+1:end) + max(1e6, rem(tus(ind_down(j)), 1e6));
        end
    end
    if ind_down
        tus = tus - PreDAU(k);
    end
%     ind_up = find(dt>T_jump);   --> after unscrambling this block is unnecessary, ind_up is always empty
%     for j = 1:length(ind_up)
%         tus(ind_up(j)+1:end) = tus(ind_up(j)+1:end) - 1e6;
%     end
    %---------------------            
        
    Tus(k).val = tus; Ttk(k).val = ttk; Typ(k).val = typ; Erg(k).val = erg; Dau(k).val = dau; Det(k).val = det;
    %---------------------
end
%**************************************************************************


%**************************************************************************
function [varargout] = GetVariables(data, names, varargin);

for k = 1:length(varargin)
    ind = strcmp(names, varargin{k});
    varargout{k} = data{ind}(:, :);
end
%**************************************************************************