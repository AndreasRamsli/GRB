function [mat_out] = spectra_from_triggers_v8(fname,wanted_time,time_window_m)

bgo_channel_spectra = cell(4,3);
temperatures = cell(4,3);
ttimess =  [] ;

temperatures = [];

temperature=[];
out_time=[];

% read the data
fn = fname;

if contains(fn,'.cdf.gz')
    gunzip(fn) ;
    fn = fn(1:end-3);
    [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
else
    [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
end

 % read data and data info;
var_names = info.Variables(:, 1);  % list of all variables names

%%

names = info.Variables(:, 1);
V_val = names; V_list.String = V_val; V_list.Value = 1;
VE_list.String = V_val;

S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
    info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};

VV_val = data{V_list.Value};

T0 = datetime(datevec(datenum(0, 1, 1, 0, 0, 0)));  % reference time

% time

if strcmp(S_val{3}, 'epoch16')
    myTime = T0 + seconds(VV_val(:, 1) + VV_val(:, 2)*1e-12);      % raw contains read epoch16 data from cdf
    myTime.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
elseif strcmp(S_val{3}, 'epoch')
    myTime = T0 + seconds(VV_val*1e-3);      % raw contains read epoch16 data from cdf
    myTime.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
end

ttimess = myTime;

nb_triggers=length(ttimess);

disp(['Found ' num2str(nb_triggers) ' triggers'])

%%

% parse data
fprintf('Parsing data ...\n');

% BGO

bgo_normal_pulse_height = single(double(data{strcmp(var_names,{'bgo_normal_pulse_height'})}));

bgo_normal_address = single(double(data{strcmp(var_names,{'bgo_normal_address'})}));

if (sum(isinf(bgo_normal_pulse_height(:)))>=1)
    error('bgo_normal_pulse_height has infinites')
end

if (sum(isinf(bgo_normal_address(:)))>=1)
    error('bgo_normal_pulse_height has infinites')
end

temperatures_array{1,1} = single(data{strcmp(var_names,{'dau_bgo_1_int_tmon_chan1'})});

if (sum(isinf(temperatures_array{1,1}))>=1)
    error('bgo_normal_pulse_height has infinites')
end

temperatures_array{1,2} = single(data{strcmp(var_names,{'dau_bgo_1_int_tmon_chan2'})});
temperatures_array{1,3} = single(data{strcmp(var_names,{'dau_bgo_1_int_tmon_chan3'})});

if (sum(isinf(temperatures_array{1,3}))>=1)
    error('temperatures_array{1,3} has infinites')
end

temperatures_array{2,1} = single(data{strcmp(var_names,{'dau_bgo_2_int_tmon_chan1'})});
temperatures_array{2,2} = single(data{strcmp(var_names,{'dau_bgo_2_int_tmon_chan2'})});
temperatures_array{2,3} = single(data{strcmp(var_names,{'dau_bgo_2_int_tmon_chan3'})});

temperatures_array{3,1} = single(data{strcmp(var_names,{'dau_bgo_3_int_tmon_chan1'})});
temperatures_array{3,2} = single(data{strcmp(var_names,{'dau_bgo_3_int_tmon_chan2'})});
temperatures_array{3,3} = single(data{strcmp(var_names,{'dau_bgo_3_int_tmon_chan3'})});

if (sum(isinf(temperatures_array{3,3}))>=1)
    error('temperatures_array{3,3} has infinites')
end

temperatures_array{4,1} = single(data{strcmp(var_names,{'dau_bgo_4_int_tmon_chan1'})});
temperatures_array{4,2} = single(data{strcmp(var_names,{'dau_bgo_4_int_tmon_chan2'})});
temperatures_array{4,3} = single(data{strcmp(var_names,{'dau_bgo_4_int_tmon_chan3'})});

temperatures = temperatures_array;

bgo_normal_pulse_height = reshape(bgo_normal_pulse_height',1,[]);
bgo_normal_address = reshape(bgo_normal_address',1,[]);

list_detector_nb = sort(unique(bgo_normal_address));

ind_to_rm = bgo_normal_address == 255;
bgo_normal_pulse_height(ind_to_rm) = [];
bgo_normal_address(ind_to_rm) = [];

list_detector_nb(list_detector_nb==255) = [];

%% removing counts if too close in time (<20 us)

[Data,~] = MakeData(fn);

datetime_list=[];
channels_list=[];
dau_list=[];
det_list=[];

for ii=1:length(Data)
    if ~isfield(Data(ii),'BGO')
        continue;
    end
    if ~isempty(Data(ii).BGO)
        [datetimes_out_tmp,channels_out_tmp,dau_out_tmp,det_out_tmp,~]=get_simplified_data(Data(ii));
        
        datetime_list = [datetime_list datetimes_out_tmp(:)'];
        channels_list = [channels_list channels_out_tmp(:)'];
        dau_list = [dau_list dau_out_tmp(:)'];
        det_list = [det_list det_out_tmp(:)'];
    end
end

if  isempty(datetime_list)
    return;
end

min_diff = min(abs(datetime_list-wanted_time));

to_keep = abs(datetime_list-wanted_time)<minutes(time_window_m);

datetime_list = datetime_list(to_keep);
channels_list = channels_list(to_keep);
dau_list = dau_list(to_keep);
det_list = det_list(to_keep);

mat_out=[year(datetime_list(:)) month(datetime_list(:)) day(datetime_list(:))...
    hour(datetime_list(:)) minute(datetime_list(:)) second(datetime_list(:)) ...
    channels_list(:) dau_list(:) det_list(:)];

if sum(to_keep)==0
    warning(['in this file, there are no triggers counts ' num2str(time_window_m) ' minutes around the specified time. Closest: ' num2str(minutes(min_diff)) ' minutes'])
end

end

%%
%**************************************************************************
function [Data,skipped] = MakeData(fn)
global nb_trigger_bug;
global nb_trigger_read;

Data = struct;

[data, info] = spdfcdfread(fn);  % read data and data info; this function closes the file itself
names = info.Variables(:, 1);    % list of all variables names

[year, s, ms, DPU, PreDAU] = GetVariables(data, names, 'utc_year', 'utc_seconds', 'utc_msec', 'dpu_count', 'dpu_count_prereset');
year = double(year); s = double(s); ms = double(ms); DPU = int32(DPU); PreDAU = int32(PreDAU);
N = length(s);                   % number of triggers in file

[Lat, Lon, DC, MX] = GetVariables(data, names, 'latitude', 'longitude', 'detector_counts', 'mxgs_trig_count');

skipped=0;

for k = 1:N
    
    try
        
        T0 = datetime(datevec(datenum(year(k), 1, 1, 0, 0, 0)));
        
        Data(k).T0 = T0;
        Data(k).Lat = Lat(k);
        Data(k).Lon = Lon(k);
        Data(k).Tsc = s(k);
        Data(k).Tms = ms(k);
        
        dc = DC(k, DC(k, :)<3e14);               % take trigger k, remove pad values
        mx = MX(k);                              % trigger MXGS count
        if mx>0
            ind = find(dc==mx);                  % find index of
        else
            ind = [];
        end
        
        dc = dec2bin(dc, 64);                    % convert to binary 64
        dc = dc(:, 17:end);                      % cut first 16 not used bits
        
        % time block ==========================================================
        tus = int32(bin2dec(dc(:, end-19:end))); % ALL tus (BGO + CZT), last 20 bits, int32 --> can operate with negatives
        
        % find TCP boundaries
        Utus = tus;               % scrambled stairs-2e6
        dt = diff(Utus);
        T_jump = 6e5;             % this works with uncorrupted data; for corrupted data result is crap
        ind_down = find(dt<-T_jump);
        for j = 1:length(ind_down)
            Utus(ind_down(j)+1:end) = Utus(ind_down(j)+1:end) + 2e6;
        end
        ind_up = find(dt>T_jump);
        for j = 1:length(ind_up)
            Utus(ind_up(j)+1:end) = Utus(ind_up(j)+1:end) - 2e6;
        end
        [~, I1] = sort(Utus);     % sort stairs-2e6 by time --> this is the right time order!!!
        tus = tus(I1);            % unscrambled saw
        
        if ind
            ind1 = find(I1==ind); % number of trigger count in sorted array
        else
            ind1 = [];
        end
        
        dt = diff(tus);
        ind_down = find(dt<-T_jump);
        nTCP = length(ind_down);  % number of TCPs
        
        % find reference TCP --------------------------------------------------
        tusDirty = tus;
        for j = 1:nTCP
            tusDirty(ind_down(j)+1:end) = tusDirty(ind_down(j)+1:end) + 1e6;
        end
        TrigLen = tusDirty(end) - tusDirty(1);  % trigger length in microseconds
        
        tusDirty = tus;
        
        if isempty(ind1) && (TrigLen<2e6 || TrigLen>2.02e6)
            refTCP = 1;
        else
            if ind1
                refTCP = find((ind_down+1)<ind1, 1, 'last');  % find TCP number before the MXGS trigger
            else
                mDPU = DPU(k);
                refTCP = 1;
                for j = 0:nTCP
                    mDPU = mDPU + (j*1e6);
                    ratio = sum(tusDirty<mDPU)/sum(tusDirty>mDPU);
                    if ratio>(2/3) && ratio<(3/2)
                        refTCP = j;
                        break
                    end
                end
            end
        end
        %----------------------------------------------------------------------
        
        % set up zero ---------------------------------------------------------
        for j = 1:refTCP-1
            tus(1:ind_down(j)) = tus(1:ind_down(j)) - max(1e6, rem(tus(ind_down(j)), 1e6));
        end
        
        for j = refTCP
            if refTCP>0
                tus(1:ind_down(j)) = tus(1:ind_down(j)) - PreDAU(k);
            end
        end
        
        for j = refTCP+1:nTCP
            tus(ind_down(j)+1:end) = tus(ind_down(j)+1:end) + max(1e6, rem(tus(ind_down(j)), 1e6));
        end
        %----------------------------------------------------------------------
        % end of time block ===================================================
        
        
        % other variables =====================================================
        
        %     Data(k).tus0 = bin2dec(dc(:, 29:48));  % unsorted, intact tus
        
        dc = dc(I1, :);   % sort everything by time order
        
        flag = bin2dec(dc(:, 1:2));  % flag, 0 for CZT, 2 for BGO
        IC = flag==0;             % indices of CZT
        IB = flag==2;             % indices of BGO
        if sum(IC)+sum(IB)~=length(flag)
            disp('BGO + CZT ~= DATA.  Some counts are corrupted. Corruption everywhere!')
        end
        
        
        % CZT ---------------------------
        Data(k).CZT.tus = tus(IC);                 % CZT reconstructed, ordered, referenced tus
        Data(k).CZT.dau = bin2dec(dc(IC, 3:4));    % CZT dau, ordered
        Data(k).CZT.add = bin2dec(dc(IC, 5:9));    % CZT ASIC address, ordered
        Data(k).CZT.chn = bin2dec(dc(IC, 10:16));  % CZT ASIC channel, ordered
        Data(k).CZT.erg = bin2dec(dc(IC, 17:26));  % CZT pulse height, ordered
        Data(k).CZT.mlh = bin2dec(dc(IC, 27:28));  % CZT milti-hit flag, ordered
        Data(k).CZT.tus0 = bin2dec(dc(IC, 29:48)); % CZT raw tus, ordered
        %--------------------------------
        
        
        % BGO ---------------------------
        Data(k).BGO.tus = tus(IB);                 % BGO reconstructed, ordered, referenced tus
        Data(k).BGO.dau = bin2dec(dc(IB, 3:4));    % BGO dau, ordered
        Data(k).BGO.det = bin2dec(dc(IB, 5:6));    % BGO det, ordered
        Data(k).BGO.typ = ceil(bin2dec(dc(IB, 7:9))/2); % BGO type, ordered NRM=0, FST=1, OVF=2, VAL=3
        Data(k).BGO.ttk = bin2dec(dc(IB, 11:16));  % BGO 36 MHz ticks, ordered
        Data(k).BGO.erg = bin2dec(dc(IB, 17:28));  % BGO pulse height, ordered
        Data(k).BGO.tus0 = bin2dec(dc(IB, 29:48)); % BGO raw tus, ordered
        
        nb_trigger_read = nb_trigger_read+1;
        
    catch ME
        
        disp('Error while reading trigger. Skipping.')
        skipped=skipped+1;
        nb_trigger_bug = nb_trigger_bug+1;
        
    end
    
    
    %======================================================================
end
end
%**************************************************************************


%**************************************************************************
function [varargout] = GetVariables(data, names, varargin);

for k = 1:length(varargin)
    ind = strcmp(names, varargin{k});
    varargout{k} = data{ind}(:, :);
end
end
%**************************************************************************

function [datetimes_out,channels_out,dau_out,det_out,T_ref]=get_simplified_data(Data)

leap = -18;

T0 = Data.T0; tsc = Data.Tsc; tms = Data.Tms;

tusB = Data.BGO.tus; ttkB = Data.BGO.ttk;
typB = Data.BGO.typ; ergB = Data.BGO.erg;
dauB = Data.BGO.dau; detB = Data.BGO.det;

% tusC = Data.CZT.tus;
% ergC = Data.CZT.erg;
% dauC = Data.CZT.dau; % [0:3]
% addC = Data.CZT.add; % [0:31]
% chnC = Data.CZT.chn; % [0:127]
% mlhC = Data.CZT.mlh; % [0:3]

adrB = (dauB-1)*3 + detB;        % converts dau-det into detector number in range of [1:12]

[~, I] = sort(36*double(tusB) + double(ttkB));  % time sorting including 36 MHz ticks
tusB = tusB(I); ttkB = ttkB(I); typB = typB(I); ergB = ergB(I); adrB = adrB(I);
dauB=dauB(I);detB=detB(I);

I = typB==0;                    % keep only normal events
tusB = tusB(I); ttkB = ttkB(I); typB = typB(I); ergB = ergB(I); adrB = adrB(I);
dauB=dauB(I);detB=detB(I);

tusB_full = double(tusB) + double(ttkB)/36;   % time with sub-us precision

T = T0 + seconds(double(tsc + leap) + double(tms)*1e-3);  % time reference
T.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';

datetimes_out = T + milliseconds(tusB_full/1000.0);
datetimes_out.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
channels_out = ergB;
dau_out = dauB;
det_out = detB;
T_ref = T;

end

%%

function [TUS_2,DAU_2,DET_2,TYP_2,ERG_2] = remove_comic_showers(TUS,DAU,DET,TYP,ERG,NUMNER_OF_DETECTORS_THRESHOLD)

dt = 0.25; % us

[TUS_2,is] = sort(TUS);
DAU_2 = DAU(is);
DET_2 = DET(is);
TYP_2 = TYP(is);
ERG_2 = ERG(is);

NB_DET = DAU_2 .* 3 + DET_2+1; % number between 1 and 12

to_rm = [];

for ii=1:length(TUS_2)
    kept_t = TUS_2>TUS_2(ii)-dt/2 & TUS_2<TUS_2(ii)+dt/2;
    
    nb_det_triggered = length(unique(NB_DET(kept_t)));
    
    if nb_det_triggered >= NUMNER_OF_DETECTORS_THRESHOLD
        to_rm = [to_rm find(kept_t)'];
    end
end

if isempty(to_rm)
   return; 
end

to_rm = unique(to_rm);

TUS_2(to_rm) = [];
DAU_2(to_rm) = [];
DET_2(to_rm) = [];
TYP_2(to_rm) = [];
ERG_2(to_rm) = [];

end