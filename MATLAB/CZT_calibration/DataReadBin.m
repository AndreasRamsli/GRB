function [Data] = DataReadBin(year, DOY, K, k);

% This function reads MXGS data from original binary counts. If MXGS
% trigger was reported, it finds it. 
% [lat, lon, T0, tsc, tms, tus, ttk, typ, erg, dau, det] = DataReadBin(year, DOY, F_num, Tr_num);
% This call makes ML data for one specific trigger of a specified file of DOY for MXGS data. 
% [Lat, Lon, T0, Tsc, Tms, Tus, Ttk, Typ, Erg, Dau, Det] = DataReadBin(year, DOY, F_num);
% This call makes ML data for all triggers from a specified file of DOY for MXGS data. 

%---------------------

%---------------------
%DirPrefix = '/Volumes/Helheim/Data/ASIM/';
DirPrefix = '/net_krb5/felles3.uib.no/vol/ift_asdc/bulktransfer2/ops/';
DataDir = [DirPrefix 'MXGS/cdf/mxgstgfobservation/'];

DOY_Path = [DataDir int2str(year) '/' sprintf('%03d', DOY) '/'];
% K = varargin{1};
try
    list = dir([DOY_Path, '*cdf']); % list of cdf files in DOY folder
    fn = [DOY_Path  list(K).name];
catch
    disp('Something is wrong with data path. Check YEAR, DOY and file number.')
    return
end


try     
    [Data] = MakeData(fn, k);
catch
    disp('Something is wrong with required trigger number.')
end

% if length(varargin)==2
%     try
%         k = varargin{2};
%         [Data] = MakeData(fn, k);
%     catch
%         disp('Something is wrong with required trigger number.')
% %         disp(['Total number of triggers is ' int2str(length(Tus)) '.'])
%     end
% else
%     [Data] = MakeData(fn, 0);
% end


%**************************************************************************
function [Data] = MakeData(fn, kk);
Data = struct;

[data, info] = spdfcdfread(fn);  % read data and data info; this function closes the file itself
Data.data = data;
Data.info = info;
names = info.Variables(:, 1);    % list of all variables names

[year, s, ms, xTCP, DPU, PreDAU, ID] = GetVariables(data, names, 'utc_year', 'utc_seconds', 'utc_msec',...
                                 'tcp_count_dhpu', 'dpu_count', 'dpu_count_prereset', 'unique_name_string');
year = double(year); s = double(s); ms = double(ms); xTCP = double(xTCP); DPU = int32(DPU); PreDAU = int32(PreDAU);
N = length(s);                   % number of triggers in file

[Lat, Lon, DC, MX] = GetVariables(data, names, 'latitude', 'longitude', 'detector_counts', 'mxgs_trig_count'); 

for k = kk
    
    T0 = datetime(datevec(datenum(year(k), 1, 1, 0, 0, 0)));
    
    Data.ID = ID(k, :);
    Data.TCP = xTCP(k);
    Data.T0 = T0;
    Data.Lat = Lat(k);
    Data.Lon = Lon(k);
    Data.Tsc = s(k);
    Data.Tms = ms(k);
    
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
    
    Data.tus0 = bin2dec(dc(:, 29:48));  % unsorted, intact tus
    
    dc = dc(I1, :);   % sort everything by time order
    
    flag = bin2dec(dc(:, 1:2));  % flag, 0 for CZT, 2 for BGO
    IC = flag==0;             % indices of CZT
    IB = flag==2;             % indices of BGO
    if sum(IC)+sum(IB)~=length(flag)
        disp('BGO + CZT ~= DATA.  Some counts are corrupted. Corruption everywhere!')
    end
    
    % CZT ---------------------------
    Data.CZT.tus = tus(IC);                 % CZT reconstructed, ordered, referenced tus         
    Data.CZT.dau = bin2dec(dc(IC, 3:4));    % CZT dau, ordered
    Data.CZT.add = bin2dec(dc(IC, 5:9));    % CZT ASIC address, ordered
    Data.CZT.chn = bin2dec(dc(IC, 10:16));  % CZT ASIC channel, ordered
    Data.CZT.erg = bin2dec(dc(IC, 17:26));  % CZT pulse height, ordered
    Data.CZT.mlh = bin2dec(dc(IC, 27:28));  % CZT milti-hit flag, ordered
    Data.CZT.tus0 = bin2dec(dc(IC, 29:48)); % CZT raw tus, ordered   
    CZT_tus = {Data.CZT.tus};
    %--------------------------------
    
    
    % BGO ---------------------------
    Data.BGO.tus = tus(IB);                 % BGO reconstructed, ordered, referenced tus         
    Data.BGO.dau = bin2dec(dc(IB, 3:4));    % BGO dau, ordered
    Data.BGO.det = bin2dec(dc(IB, 5:6));    % BGO dau, ordered
    Data.BGO.typ = ceil(bin2dec(dc(IB, 7:9))/2); % BGO type, ordered NRM=0, FST=1, OVF=2, VAL=3
    Data.BGO.ttk = bin2dec(dc(IB, 11:16));  % BGO 36 MHz ticks, ordered
    Data.BGO.erg = bin2dec(dc(IB, 17:28));  % BGO pulse height, ordered
    Data.BGO.tus0 = bin2dec(dc(IB, 29:48)); % BGO raw tus, ordered
    
    dau = Data.BGO.dau+1; det = Data.BGO.det+1;            
    adr = (dau-1)*3 + det;                  % converts dau-det into detector number in range of [1:12]
    Data.BGO.adr = adr;                     % BGO detector address, [1:12]
    h = scatter(Data.CZT.tus, Data.CZT.erg);
    %h2 = scatter(Data.BGO.tus, Data.BGO.erg)

    %--------------------------------  
    
    
    %======================================================================

end
%**************************************************************************
%filename =  ['output/test.mat'];
%save(filename, '-struct', '-v7');

%**************************************************************************
function [varargout] = GetVariables(data, names, varargin);

for k = 1:length(varargin)
    ind = strcmp(names, varargin{k});
    varargout{k} = data{ind}(:, :);
end
%**************************************************************************