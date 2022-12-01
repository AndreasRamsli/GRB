function CDF_GUI();

% This GUI shows list of cdf files in subfolders.

addpath ./NASA_CDF_PATCH/

TargetDir = '/scratch/ASDC/net/felles3.uib.no/vol/ift_asdc/bulktransfer2/ops/MXGS/cdf/' % global var

T0 = datetime(datevec(datenum(0, 1, 1, 0, 0, 0)));  % reference time

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off');
f.Units = 'normalized';

% Assign the a name to appear in the window title.
f.Name = 'CDF GUI';

% Move the window to the center of the screen.
movegui(f,'center')
f.Position = [0 0 1 1];
f.Resize = 'off';

% create tab_group
tabgp = uitabgroup(f, 'Position', [0 0 1 1]);
tab1 = uitab(tabgp, 'Title', 'CDF Data Files');
tab2 = uitab(tabgp, 'Title', 'Selected File Variables');
tab3 = uitab(tabgp, 'Title', 'Export Selected Variables');
% tab4 = uitab(tabgp, 'Title', 'Timestamp Missing');
%--------------------


% global vars --------
HomeDir = pwd;
%---------------------


% Measures ---------
dx = 0.03; dy = 0.03;
TopLine = 0.94;
%-------------------


% Construct Tab1 components------------------------------------------------
% List of folders --
cd(TargetDir)        
F = dir;     % list of all objects in current folder
cd(HomeDir)        
F_val = {}; j = 0;
for k = 1:length(F)
    if (F(k).isdir==1) && ~(strcmp(F(k).name, '.')) && ~(strcmp(F(k).name, '..')) ...
            && ~(strcmp(F(k).name, 'mxgssampleddetectorcounts')) && ~(strcmp(F(k).name, 'mxgssampleddetectorcountslevel1'))
        j = j + 1;
        F_val{j} = F(k).name;
    end
end
F_w = 0.27; F_h = 0.7;
F_x = dx; F_y = TopLine - F_h; 
F_list = uicontrol('Style', 'listbox', 'String', F_val, 'FontName', 'Arial', 'FontSize', 14, ...
           'Units', 'normalized', 'Position', [F_x, F_y, F_w, F_h], 'Max', 1, ...
           'Callback', @F_list_Callback, 'Enable', 'on', 'Parent', tab1);

% Caption -----------
tF_w = F_w; tF_h = dy;
tF_x = F_x; tF_y = TopLine + dy/4; 
text_F = uicontrol('Style', 'text', 'String', 'List of Folders', 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [tF_x, tF_y, tF_w, tF_h], 'Parent', tab1);
%--------------------        
%--------------------


% List of years -----
cd(TargetDir)        
folder = F_val{F_list.Value}; cd(folder)
Y = dir;     % list of all objects in current folder
Y_val = {}; j = 0;
for k = 1:length(Y)
    if (Y(k).isdir==1) && ~(strcmp(Y(k).name, '.')) && ~(strcmp(Y(k).name, '..'))            
        j = j + 1;
        Y_val{j} = Y(k).name;
    end
end
cd(HomeDir)

Y_w = 0.1; Y_h = 0.1;
Y_x = F_w + F_x + dx; Y_y = TopLine - Y_h; 
Y_list = uicontrol('Style', 'listbox', 'String', Y_val, 'FontName', 'Arial', 'FontSize', 14, ...
           'Units', 'normalized', 'Position', [Y_x, Y_y, Y_w, Y_h], 'Max', 1, ...
           'Callback', @Y_list_Callback, 'Enable', 'on', 'Parent', tab1);

% Caption -----------
tY_w = Y_w; tY_h = dy;
tY_x = Y_x; tY_y = TopLine + dy/4; 
text_Y = uicontrol('Style', 'text', 'String', 'List of Years', 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [tY_x, tY_y, tY_w, tY_h], 'Parent', tab1);
%--------------------        
%--------------------


% List of days ------
cd(TargetDir)        
folder = [F_val{F_list.Value} '/' Y_val{Y_list.Value}]; cd(folder)
D = dir;     % list of all objects in current folder
D_val = {}; j = 0;
for k = 1:length(D)
    if (D(k).isdir==1) && ~(strcmp(D(k).name, '.')) && ~(strcmp(D(k).name, '..'))            
        j = j + 1;
        D_val{j} = D(k).name;
    end
end
cd(HomeDir)

D_w = 0.1; D_h = 0.3;
D_x = Y_x + Y_w + dx; D_y = TopLine - D_h; 
D_list = uicontrol('Style', 'listbox', 'String', D_val, 'FontName', 'Arial', 'FontSize', 14, ...
           'Units', 'normalized', 'Position', [D_x, D_y, D_w, D_h], 'Max', 1, ...
           'Callback', @D_list_Callback, 'Enable', 'on', 'Parent', tab1);

% Caption -----------
tD_w = D_w; tD_h = dy;
tD_x = D_x; tD_y = TopLine + dy/4; 
text_D = uicontrol('Style', 'text', 'String', 'List of Days', 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [tD_x, tD_y, tD_w, tD_h], 'Parent', tab1);
%--------------------        
%--------------------


% List of files -----
cd(TargetDir)        
folder = [F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{D_list.Value}]; cd(folder)
df = dir;     % list of all objects in current folder
f_val = {}; j = 0;
for k = 1:length(df)
    if df(k).isdir==0
        j = j + 1;
        f_val{j} = df(k).name;
    end
end
cd(HomeDir)

f_x = D_x + D_w + dx; f_w = 1 - f_x - dx; 
f_h = 0.89; f_y = TopLine - f_h; 
f_list = uicontrol('Style', 'listbox', 'String', f_val, 'FontName', 'Arial', 'FontSize', 12, ...
           'Units', 'normalized', 'Position', [f_x, f_y, f_w, f_h], 'Max', 1, ...
           'Callback', @f_list_Callback, 'Enable', 'on', 'Parent', tab1);

% Caption -----------
tf_w = f_w; tf_h = dy;
tf_x = f_x; tf_y = TopLine + dy/4; 
LoF_text = ['List of Files.          Number of Variables in selected File: '];
text_f = uicontrol('Style', 'text', 'String', LoF_text, 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [tf_x, tf_y, tf_w, tf_h], 'Parent', tab1);
%--------------------        
%--------------------


% default file list of variables
cd(TargetDir)   
folder = [F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{D_list.Value}]; cd(folder)
fn = f_val{f_list.Value};  % selected cdf data file name
if contains(fn,'.cdf.gz')
    gunzip(fn) ;
    fn = fn(1:end-3);
    [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
else
    [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
end
%[data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
names = info.Variables(:, 1);  % list of all variables names
text_f.String = [LoF_text int2str(length(names)) '.'];
V_val = names; V_list.String = V_val;
N_of_Obs = length(data{strcmp(V_val, 'raw_datetime')});  % number of observations in file
VE_list.String = V_val;
cd(HomeDir)        
%--------------------

%--------------------------------------------------------------------------


% Construct Tab2 components------------------------------------------------
% List of variables -
V_val = names;

V_w = 0.27; V_h = 0.9;
V_x = dx; V_y = TopLine - V_h; 
V_list = uicontrol('Style', 'listbox', 'String', V_val, 'FontName', 'Arial', 'FontSize', 14, ...
           'Units', 'normalized', 'Position', [V_x, V_y, V_w, V_h], 'Max', 1, ...
           'Callback', @V_list_Callback, 'Enable', 'on', 'Parent', tab2);

% Caption -----------
tV_w = V_w; tV_h = dy;
tV_x = V_x; tV_y = TopLine + dy/4; 
text_V = uicontrol('Style', 'text', 'String', 'List of Variables', 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [tV_x, tV_y, tV_w, tV_h], 'Parent', tab2);
%--------------------        
%--------------------


% Selected variable -
S1_val = {'Name'; 'Size'; 'Type'; 'Pad val'};

S1_w = 0.05; S1_h = 0.1;
S1_x = V_x + V_w + dx; S1_y = TopLine - S1_h; 
text_S1 = uicontrol('Style', 'text', 'String', S1_val, 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [S1_x, S1_y, S1_w, S1_h], 'HorizontalAlignment', 'left', 'Parent', tab2);
%--------------------        

% Selected variable -
S2_val = {'-->'; '-->'; '-->'; '-->'};

S2_w = S1_w/2; S2_h = S1_h;
S2_x = S1_x + S1_w; S2_y = S1_y; 
text_S2 = uicontrol('Style', 'text', 'String', S2_val, 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [S2_x, S2_y, S2_w, S2_h], 'HorizontalAlignment', 'left', 'Parent', tab2);
%--------------------        

% Selected variable -
S_val = {info.Variables{V_list.Value, 1}; num2str(info.Variables{V_list.Value, 2});...
         info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};

S_w = 0.5; S_h = S1_h;
S_x = S2_x + S2_w; S_y = S1_y; 
text_S = uicontrol('Style', 'text', 'String', S_val, 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [S_x, S_y, S_w, S_h], 'HorizontalAlignment', 'left', 'Parent', tab2);
%--------------------       


% Variable Value ----
VV_val = data{V_list.Value};

N_of_Obs = length(data{strcmp(V_val, 'raw_datetime')});  % number of observations in file
% disp(N_of_Obs)

if strcmp(S_val{3}, 'epoch16')
    temp = T0 + seconds(VV_val(:, 1) + VV_val(:, 2)*1e-12);      % raw contains read epoch16 data from cdf
    temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
    ToShow = char(temp);
else
    if strcmp(S_val{3}, 'epoch')
        temp = T0 + seconds(VV_val*1e-3);      % raw contains read epoch16 data from cdf
        temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
        ToShow = char(temp);    
    else
        if strcmp(S_val{3}, 'char')
            ToShow = VV_val;
        else
            ToShow = VV_val(:, 1);
        end
    end
end

VV_w = 0.5; VV_h = TopLine - S1_h - (2 * dy);
VV_x = V_x + V_w + dx; VV_y = V_y; 
VV_list = uicontrol('Style', 'listbox', 'String', ToShow, 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [VV_x, VV_y, VV_w, VV_h], 'Enable', 'inactive', 'Parent', tab2);
%--------------------      
%--------------------------------------------------------------------------



% Construct Tab3 components------------------------------------------------
% List of variables -
VE_list = uicontrol('Style', 'listbox', 'String', V_val, 'FontName', 'Arial', 'FontSize', 14, ...
           'Units', 'normalized', 'Position', [V_x, V_y, V_w, V_h], 'Max', 2, ...
           'Enable', 'on', 'Parent', tab3);

% Caption -----------
text_VE = uicontrol('Style', 'text', 'String', 'List of Variables', 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [tV_x, tV_y, tV_w, tV_h], 'Parent', tab3);
%--------------------        


% Export button -----
E_w = 0.1; E_h = 0.1;
E_x = V_x + V_w + dx; E_y = 0.5;
Export_b = uicontrol('Style', 'pushbutton', 'String', 'Export', 'Units', 'normalized', ...
             'Position', [E_x, E_y, E_w, E_h], 'Parent', tab3, 'Enable', 'on', 'Callback', @Export_Callback);
%-------------------- 

%--------------------------------------------------------------------------



% Make the window visible.
f.Visible = 'on';



% Callback functions ------------------------------------------------------
  function F_list_Callback(source, eventdata) 
        cd(TargetDir)        
        % List of years -----
        folder = F_val{source.Value}; cd(folder)
        Y = dir;     % list of all objects in current folder
        Y_val = {}; j = 0;
        for k = 1:length(Y)
            if (Y(k).isdir==1) && ~(strcmp(Y(k).name, '.')) && ~(strcmp(Y(k).name, '..'))            
                j = j + 1;
                Y_val{j} = Y(k).name;
            end
        end
        Y_list.String = Y_val; Y_list.Value = 1;
        %---------------------
        
        % List of days ------
        folder = Y_val{Y_list.Value}; cd(folder)
        D = dir;     % list of all objects in current folder
        D_val = {}; j = 0;
        for k = 1:length(D)
            if (D(k).isdir==1) && ~(strcmp(D(k).name, '.')) && ~(strcmp(D(k).name, '..'))            
                j = j + 1;
                D_val{j} = D(k).name;
            end
        end
        D_list.String = D_val; D_list.Value = 1;
        %---------------------
        
        % List of files -----
        folder = D_val{D_list.Value}; cd(folder)
        df = dir;     % list of all objects in current folder
        f_val = {}; j = 0;
        for k = 1:length(df)
            if df(k).isdir==0
                j = j + 1;
                f_val{j} = df(k).name;
            end
        end
        f_list.String = f_val; f_list.Value = 1;
        %---------------------

        fn = f_val{f_list.Value};  % selected cdf data file name
        if contains(fn,'.cdf.gz')
            gunzip(fn) ;
            fn = fn(1:end-3);
            [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
        else
            [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
        end
        %[data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
        names = info.Variables(:, 1);  % list of all variables names
        text_f.String = [LoF_text int2str(length(names)) '.'];
        V_val = names; V_list.String = V_val; V_list.Value = 1;
        N_of_Obs = length(data{strcmp(V_val, 'raw_datetime')});  % number of observations in file
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
     
        VV_val = data{V_list.Value};
        
        if strcmp(S_val{3}, 'epoch16')
            temp = T0 + seconds(VV_val(:, 1) + VV_val(:, 2)*1e-12);      % raw contains read epoch16 data from cdf
            temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
            ToShow = char(temp);
        else
            if strcmp(S_val{3}, 'epoch')
                temp = T0 + seconds(VV_val*1e-3);      % raw contains read epoch16 data from cdf
                temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
                ToShow = char(temp);    
            else
                if strcmp(S_val{3}, 'char')
                    ToShow = VV_val;
                else
                    ToShow = VV_val(:, 1);
                end
            end
        end

        VV_list.String = ToShow; VV_list.Value = 1;

        cd(HomeDir)        
  end


  function Y_list_Callback(source, eventdata) 
        cd(TargetDir)        
        % List of days ------
        folder = [F_val{F_list.Value} '/' Y_val{source.Value}]; cd(folder)
        D = dir;     % list of all objects in current folder
        D_val = {}; j = 0;
        for k = 1:length(D)
            if (D(k).isdir==1) && ~(strcmp(D(k).name, '.')) && ~(strcmp(D(k).name, '..'))            
                j = j + 1;
                D_val{j} = D(k).name;
            end
        end
        D_list.String = D_val; D_list.Value = 1;
        %---------------------
        
        % List of files -----
        folder = D_val{D_list.Value}; cd(folder)
        df = dir;     % list of all objects in current folder
        f_val = {}; j = 0;
        for k = 1:length(df)
            if df(k).isdir==0
                j = j + 1;
                f_val{j} = df(k).name;
            end
        end
        f_list.String = f_val; f_list.Value = 1;
        %---------------------

        fn = f_val{f_list.Value};  % selected cdf data file name
        if contains(fn,'.cdf.gz')
            gunzip(fn) ;
            fn = fn(1:end-3);
            [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
        else
            [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
        end
        %[data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
        names = info.Variables(:, 1);  % list of all variables names
        text_f.String = [LoF_text int2str(length(names)) '.'];
        V_val = names; V_list.String = V_val; V_list.Value = 1;
        N_of_Obs = length(data{strcmp(V_val, 'raw_datetime')});  % number of observations in file
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
        
        VV_val = data{V_list.Value};
        
        if strcmp(S_val{3}, 'epoch16')
            temp = T0 + seconds(VV_val(:, 1) + VV_val(:, 2)*1e-12);      % raw contains read epoch16 data from cdf
            temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
            ToShow = char(temp);
        else
            if strcmp(S_val{3}, 'epoch')
                temp = T0 + seconds(VV_val*1e-3);      % raw contains read epoch16 data from cdf
                temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
                ToShow = char(temp);    
            else
                if strcmp(S_val{3}, 'char')
                    ToShow = VV_val;
                else
                    ToShow = VV_val(:, 1);
                end
            end
        end
        
        VV_list.String = ToShow; VV_list.Value = 1;
        
        cd(HomeDir)        
  end


  function D_list_Callback(source, eventdata)
        cd(TargetDir)        
        % List of files -----
        folder = [F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{source.Value}]; cd(folder)
        df = dir;     % list of all objects in current folder
        f_val = {}; j = 0;
        for k = 1:length(df)
            if df(k).isdir==0
                j = j + 1;
                f_val{j} = df(k).name;
            end
        end
        f_list.String = f_val; f_list.Value = 1;
        %---------------------

        fn = f_val{f_list.Value};  % selected cdf data file name
        if contains(fn,'.cdf.gz')
            gunzip(fn) ;
            fn = fn(1:end-3);
            [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
        else
            [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
        end
        %[data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
        names = info.Variables(:, 1);  % list of all variables names
        text_f.String = [LoF_text int2str(length(names)) '.'];
        V_val = names; V_list.String = V_val; V_list.Value = 1;
        N_of_Obs = length(data{strcmp(V_val, 'raw_datetime')});  % number of observations in file
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
        
        VV_val = data{V_list.Value};
        
        if strcmp(S_val{3}, 'epoch16')
            temp = T0 + seconds(VV_val(:, 1) + VV_val(:, 2)*1e-12);      % raw contains read epoch16 data from cdf
            temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
            ToShow = char(temp);
        else
            if strcmp(S_val{3}, 'epoch')
                temp = T0 + seconds(VV_val*1e-3);      % raw contains read epoch16 data from cdf
                temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
                ToShow = char(temp);    
            else
                if strcmp(S_val{3}, 'char')
                    ToShow = VV_val;
                else
                    ToShow = VV_val(:, 1);
                end
            end
        end
        
        VV_list.String = ToShow; VV_list.Value = 1;
        
        cd(HomeDir)        
  end


  function f_list_Callback(source, eventdata)
      cd(TargetDir)
      folder = [F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{D_list.Value}]; cd(folder)
      fn = f_val{source.Value};  % selected cdf data file name
      if contains(fn,'.cdf.gz')
          gunzip(fn) ;
          fn = fn(1:end-3);
          [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
      else
          [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1);
      end
      %[data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
      names = info.Variables(:, 1);  % list of all variables names
      text_f.String = [LoF_text int2str(length(names)) '.'];
      V_val = names; V_list.String = V_val; V_list.Value = 1;
        N_of_Obs = length(data{strcmp(V_val, 'raw_datetime')});  % number of observations in file
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
        
        VV_val = data{V_list.Value};
        
        if strcmp(S_val{3}, 'epoch16')
            temp = T0 + seconds(VV_val(:, 1) + VV_val(:, 2)*1e-12);      % raw contains read epoch16 data from cdf
            temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
            ToShow = char(temp);
        else
            if strcmp(S_val{3}, 'epoch')
                temp = T0 + seconds(VV_val*1e-3);      % raw contains read epoch16 data from cdf
                temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
                ToShow = char(temp);    
            else
                if strcmp(S_val{3}, 'char')
                    ToShow = VV_val;
                else
                    ToShow = VV_val(:, 1);
                end
            end
        end
        
        VV_list.String = ToShow; VV_list.Value = 1;
        
        cd(HomeDir)        
  end

  
  function V_list_Callback(source, eventdata)
        S_val = {info.Variables{source.Value, 1};num2str(info.Variables{source.Value, 2});...
                 info.Variables{source.Value, 4}; num2str(info.Variables{source.Value, 9})};
        text_S.String = S_val; 
        
        VV_val = data{source.Value};
        
        if strcmp(S_val{3}, 'epoch16')
            temp = T0 + seconds(VV_val(:, 1) + VV_val(:, 2)*1e-12);      % raw contains read epoch16 data from cdf
            temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
            ToShow = char(temp);
        else
            if strcmp(S_val{3}, 'epoch')
                temp = T0 + seconds(VV_val*1e-3);      % raw contains read epoch16 data from cdf
                temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
                ToShow = char(temp);    
            else
                if strcmp(S_val{3}, 'char')
                    ToShow = VV_val;
                else
                    ToShow = VV_val(:, 1);
                end
            end
        end
        
        VV_list.String = ToShow; VV_list.Value = 1;      
  end


  function Export_Callback(source, eventdata)
        VarInd = VE_list.Value;
        
        VarNames = {};
        for k = 1:length(VarInd)
            VarNames{k} = V_val{VarInd(k)};
        end
        
        Labels = VarNames;
        
        VarData = {};
        for k = 1:length(VarInd)
            VarData{k} = data{VarInd(k)};
        end
        
        export2wsdlg(Labels, VarNames, VarData, 'Export Selected Variables to Workspace');
  end

%--------------------------------------------------------------------------

end