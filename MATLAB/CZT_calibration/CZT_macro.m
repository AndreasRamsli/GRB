clear all;
close all;

TGF_str_Andrew = '2019-06-28 04:23:33.49023';
xmin=-99999999999999;
xmax=99999999999999;
tus_TGF=0;
year = 2019;
doy = 94;
filenumber = 6;
trigger_number = 5;

%[lat, lon, t0, tsc, tms, tus, ttk, typ, erg, dau, det] = DataReadOrder(2018,321,27,21); %  2018-Nov-17 22:26:33.634498


leap = -18;
TGF_str_Andrew = strrep(TGF_str_Andrew,':','.');
TGF_str_Andrew = strrep(TGF_str_Andrew,'-','.');
TGF_str_Andrew = strrep(TGF_str_Andrew,' ','_');
tus_min = tus_TGF + xmin;
tus_max = tus_TGF + xmax;


%trigger_number = 1:88;
savename = strcat('/Home/siv30/wad005/master/GRB/MATLAB/CZT_calibration/file_mat_CZT_TGF/',TGF_str_Andrew, ".mat");
savename_fulltrigger = strcat('/Home/siv30/wad005/master/GRB/MATLAB/CZT_calibration/file_mat_CZT_TGF/',TGF_str_Andrew,"_Fulltrigger.mat");


ans = DataReadBin(year, doy, filenumber, trigger_number); % SCIENCE

data = ans.data;
info = ans.info;

var_names = info.Variables(:, 1);  % list of all variables names
data1 = data(1,:);

czt_asic_address = double(data1{strcmp(var_names, {'czt_asic_address'})});
czt_asic_channel = double(data1{strcmp(var_names, {'czt_asic_channel'})});
czt_pulse_height = double(data1{strcmp(var_names, {'czt_pulse_height'})});
czt_timestamp = double(data1{strcmp(var_names, {'czt_timestamp'})});
czt_multi_hit = double(data1{strcmp(var_names, {'czt_multi_hit'})});

% select time window
year = double(data1{strcmp(var_names, {'utc_year'})});
s = double(data1{strcmp(var_names, {'utc_seconds'})});
ms = double(data1{strcmp(var_names, {'utc_msec'})});
DC = double(data1{strcmp(var_names, {'detector_counts'})});
MX = double(data1{strcmp(var_names, {'mxgs_trig_count'})});
PreDAU = double(data1{strcmp(var_names, {'dpu_count_prereset'})});
DPU = double(data1{strcmp(var_names, {'dpu_count'})});

year = double(year); s = double(s); ms = double(ms);
for k = trigger_number
    T0 = datetime(datevec(datenum(year(k), 1, 1, 0, 0, 0)));
    Tsc = s(k);
    Tms = ms(k);
    
    T_ref = T0 + seconds(double(Tsc + leap) + double(Tms)*1e-3);  % time reference
    T_ref.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
    
    
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
    
    % % % % %     tusDirty = tus;  % <-------------- Source of wrong timing for MMIA triggers
    
    if isempty(ind1) && (TrigLen<2e6 || TrigLen>2.02e6)
        refTCP = 1;
    else
        if ind1
            refTCP = find((ind_down+1)<ind1, 1, 'last');  % find TCP number before the MXGS trigger
        else
            mDPU = DPU(k);
            refTCP = 1;
            for j = 0:nTCP
                mDPU = DPU(k) + (j*1e6);
                ratio = sum(tusDirty<mDPU)/sum(tusDirty>mDPU);
                if ratio>(2/3) && ratio<(3/2)
                    refTCP = j;
                    break
                end
            end
        end
    end
    
    if nTCP==0
        refTCP = 0;
    end
    %----------------------------------------------------------------------
    
    %     disp(refTCP)
    
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
    
    
    dc = dc(I1, :);   % sort everything by time order
    flag = bin2dec(dc(:, 1:2));  % flag, 0 for CZT, 2 for BGO
    IC = flag==0;             % indices of CZT
    IB = flag==2;             % indices of BGO
    if sum(IC)+sum(IB)~=length(flag)
        disp('BGO + CZT ~= DATA.  Some counts are corrupted. Corruption everywhere!')
    end
    tus = tus(IC);
end;



channel_spectra_total_fulltrigger = zeros(16384,1024);
keV_spectra_total_fulltrigger = zeros(16384,1000);
channel_spectra_total = zeros(16384,1024);
keV_spectra_total = zeros(16384,1000);
for ii = trigger_number%1:2 Still a problem with this one
    
    czt_asic_address_tr = czt_asic_address(ii,:);
    czt_asic_channel_tr = czt_asic_channel(ii,:);
    czt_pulse_height_tr = czt_pulse_height(ii,:);
    czt_timestamp_tr = czt_timestamp(ii,:);
    czt_multi_hit_tr = czt_multi_hit(ii,:);
    % remove empty
    
    ind = czt_timestamp_tr > 1e9;
    czt_asic_channel_tr(ind) = [];
    czt_pulse_height_tr(ind) = [];
    czt_timestamp_tr(ind) = [];
    czt_multi_hit_tr(ind) = [];
    czt_asic_address_tr(ind) = [];
    
    
    multihit = czt_multi_hit_tr;
    multihit_fulltrigger = czt_multi_hit_tr;
    

    tus_keep_multihit = tus;
    tus_keep_multihit_fulltrigger = tus;
    erg_keep_multihit = czt_pulse_height_tr;
    erg_keep_multihit_fulltrigger = czt_pulse_height_tr;
    % remove multihits
    ind = czt_multi_hit_tr > 0;
    czt_asic_channel_tr(ind) = [];
    czt_pulse_height_tr(ind) = [];
    czt_timestamp_tr(ind) = [];
    czt_asic_address_tr(ind) = [];
    czt_multi_hit_tr(ind) = [];
    ind = ind.';

    if length(trigger_number) == 1
        tus = tus(~ind);
        tus_fulltrigger = tus;
    end
    erg_fulltrigger = czt_pulse_height_tr; 
    
    [channel_spectra_fulltrigger, keV_spectra_fulltrigger, pixel_energy_fulltrigger] = czt_make_spectra_per_pixel(czt_asic_address_tr, czt_asic_channel_tr, czt_pulse_height_tr);
    channel_spectra_total_fulltrigger = channel_spectra_total_fulltrigger + channel_spectra_fulltrigger;
    keV_spectra_total_fulltrigger = keV_spectra_total_fulltrigger + keV_spectra_fulltrigger;
   
    if length(trigger_number) == 1
         % keep only inside time window
        ind = tus>=tus_min & tus<=tus_max;
        czt_asic_channel_tr(~ind) = [];
        czt_pulse_height_tr(~ind) = [];
        czt_asic_address_tr(~ind) = [];
        tus = tus(ind);
        ind = tus_keep_multihit>=tus_min & tus_keep_multihit<=tus_max;
        tus_keep_multihit = tus_keep_multihit(ind);
        erg_keep_multihit = erg_keep_multihit(ind);
        multihit = multihit(ind);
    end
    
    
    [channel_spectra, keV_spectra, pixel_energy] = czt_make_spectra_per_pixel(czt_asic_address_tr, czt_asic_channel_tr, czt_pulse_height_tr);
    channel_spectra_total = channel_spectra_total + channel_spectra;
    keV_spectra_total = keV_spectra_total + keV_spectra;
end
plot_LED(sum(channel_spectra_total,2))
erg = czt_pulse_height_tr;
T_ref_char = char(T_ref);
if length(trigger_number) == 1
    save(savename, 'keV_spectra_total', 'channel_spectra_total', 'tus', 'T_ref_char', 'erg', 'tus_keep_multihit', 'erg_keep_multihit', 'multihit', 'pixel_energy');
    save(savename_fulltrigger, 'keV_spectra_total_fulltrigger', 'channel_spectra_total_fulltrigger', 'tus_fulltrigger', 'erg_keep_multihit_fulltrigger', 'T_ref_char', 'erg_fulltrigger', 'pixel_energy_fulltrigger', 'tus_keep_multihit_fulltrigger', 'multihit_fulltrigger');
end
%histogram(tus, 100)

%stairs(sum(keV_spectra_total))
scatter(tus-tus_TGF, erg);
