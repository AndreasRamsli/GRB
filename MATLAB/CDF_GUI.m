function CDF_GUI();

% This GUI shows list of cdf files in subfolders.

addpath ('matlab_cdf370_patch-64');

T0 = datetime(datevec(datenum(0, 1, 1, 0, 0, 0)));  % reference time

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off');
f.Units = 'normalized';

% Assign the a name to appear in the window title.
f.Name = 'CDF GUI';

% Move the window to the center of the screen.
movegui(f,'center')
f.Position = [0 0 1 1];
f.Resize = 'on';

% create tab_group
tabgp = uitabgroup(f, 'Position', [0 0 1 1]);
tab1 = uitab(tabgp, 'Title', 'CDF Data Files');
tab2 = uitab(tabgp, 'Title', 'Selected File Variables');
tab3 = uitab(tabgp, 'Title', 'Export Selected Variables');
% tab4 = uitab(tabgp, 'Title', 'Timestamp Missing');
%--------------------


% global vars --------
%TargetDir = 'C:\Work\Bergen\Projects\ASIM\Data';
TargetDir = '/Volumes/ift_asdc/bulktransfer2/ops';
%TargetDir = '/Volumes/Helheim/Data/ASIM/';
f_ToShow = {};
%---------------------


% Measures ---------
dx = 0.01; dy = 0.03;
TopLine = 0.94;
%-------------------


% Construct Tab1 components------------------------------------------------
% List of Instruments 
folder = TargetDir;
I = dir(folder);     % list of all objects in current folder
I_val = {}; j = 0;
for k = 1:length(I)
    if (I(k).isdir==1) && (strcmp(I(k).name, 'DHPU') || strcmp(I(k).name, 'MMIA') || strcmp(I(k).name, 'MXGS'))
%     if (I(k).isdir==1) && ~(strcmp(I(k).name, '.')) && ~(strcmp(I(k).name, '..'))
        j = j + 1;
        I_val{j} = I(k).name;
    end
end
I_w = 0.1; I_h = 0.7;
I_x = dx; I_y = TopLine - I_h; 
I_list = uicontrol('Style', 'listbox', 'String', I_val, 'FontName', 'Arial', 'FontSize', 14, ...
           'Units', 'normalized', 'Position', [I_x, I_y, I_w, I_h], 'Max', 1, ...
           'Callback', @I_list_Callback, 'Enable', 'on', 'Parent', tab1);

% Caption -----------
tI_w = I_w; tI_h = dy;
tI_x = I_x; tI_y = TopLine + dy/4; 
text_I = uicontrol('Style', 'text', 'String', 'List of Instruments', 'FontName', 'Arial', 'FontSize', 14, ...
            'Units', 'normalized', 'Position', [tI_x, tI_y, tI_w, tI_h], 'Parent', tab1);
%--------------------        
%--------------------

% List of folders --
folder = [TargetDir '/' I_val{I_list.Value} '/cdf']; 
F = dir(folder);     % list of all objects in current folder
F_val = {}; j = 0;
for k = 1:length(F)
    if (F(k).isdir==1) && ~(strcmp(F(k).name, '.')) && ~(strcmp(F(k).name, '..'))            
        j = j + 1;
        F_val{j} = F(k).name;
    end
end

F_w = 0.27; F_h = 0.9;
F_x = I_w + I_x + dx; F_y = TopLine - F_h; 
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
folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{F_list.Value}];
Y = dir(folder);     % list of all objects in current folder
Y_val = {}; j = 0;
for k = 1:length(Y)
    if (Y(k).isdir==1) && ~(isempty(str2num(Y(k).name))) && (str2num(Y(k).name)>=2018)
        j = j + 1;
        Y_val{j} = Y(k).name;
    end
end

Y_w = 0.1; Y_h = 0.2;
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
folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{Y_list.Value}];   
D = dir(folder);     % list of all objects in current folder
D_val = {}; j = 0;
for k = 1:length(D)
    if (D(k).isdir==1) && ~(strcmp(D(k).name, '.')) && ~(strcmp(D(k).name, '..'))            
        j = j + 1;
        D_val{j} = D(k).name;
    end
end

D_w = 0.1; D_h = 0.9;
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
folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{D_list.Value}];         
df = dir(folder);     % list of all objects in current folder
f_val = {}; j = 0; f_ToShow = {};
for k = 1:length(df)
    if df(k).isdir==0
        j = j + 1;
        f_val{j} = df(k).name;
        f_ToShow{j} = [sprintf('%03d', j) ' --> ' f_val{j}];
    end
end

f_x = D_x + D_w + dx; f_w = 1 - f_x - dx; 
f_h = 0.9; f_y = TopLine - f_h; 
f_list = uicontrol('Style', 'listbox', 'String', f_ToShow, 'FontName', 'Arial', 'FontSize', 10, ...
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
folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{D_list.Value}];         
fn = [folder '/' f_val{f_list.Value}];  % selected cdf data file name
[data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
names = info.Variables(:, 1);  % list of all variables names
text_f.String = [LoF_text int2str(length(names)) '.'];
V_val = names; V_list.String = V_val;
VE_list.String = V_val;
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

ToShow = [];
Get2Show();

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
  function I_list_Callback(source, eventdata)
               
        % List of folders ----
        folder = [TargetDir '/' I_val{source.Value} '/cdf']; 
        F = dir(folder);     % list of all objects in current folder
        F_val = {}; j = 0;
        for k = 1:length(F)
            if (F(k).isdir==1) && ~(strcmp(F(k).name, '.')) && ~(strcmp(F(k).name, '..'))            
                j = j + 1;
                F_val{j} = F(k).name;
            end
        end
        F_list.String = F_val; F_list.Value = 1;
        %---------------------
        
        % List of years -----
        folder = [TargetDir '/' I_val{source.Value} '/cdf/' F_val{F_list.Value}]; 
        Y = dir(folder);     % list of all objects in current folder
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
        folder = [TargetDir '/' I_val{source.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{Y_list.Value}]; 
        D = dir(folder);     % list of all objects in current folder
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
        folder = [TargetDir '/' I_val{source.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{D_list.Value}]; 
        df = dir(folder);     % list of all objects in current folder
        f_val = {}; j = 0; f_ToShow = {};
        for k = 1:length(df)
            if df(k).isdir==0
                j = j + 1;
                f_val{j} = df(k).name;
                f_ToShow{j} = [sprintf('%03d', j) ' --> ' f_val{j}];
            end
        end
        f_list.String = f_ToShow; f_list.Value = 1;
        %---------------------
        
        fn = [folder '/' f_val{f_list.Value}];  % selected cdf data file name
        [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
        names = info.Variables(:, 1);  % list of all variables names
        text_f.String = [LoF_text int2str(length(names)) '.'];
        V_val = names; V_list.String = V_val; V_list.Value = 1;
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
     
        VV_val = data{V_list.Value};
        
        Get2Show();
        
        VV_list.String = ToShow; VV_list.Value = 1;
  end
    
    
  function F_list_Callback(source, eventdata) 
      
        % List of years -----
        folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{source.Value}]; 
        Y = dir(folder);     % list of all objects in current folder
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
        folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{source.Value} '/' Y_val{Y_list.Value}]; 
        D = dir(folder);     % list of all objects in current folder
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
        folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{source.Value} '/' Y_val{Y_list.Value} '/' D_val{D_list.Value}]; 
        df = dir(folder);     % list of all objects in current folder
        f_val = {}; j = 0; f_ToShow = {};
        for k = 1:length(df)
            if df(k).isdir==0
                j = j + 1;
                f_val{j} = df(k).name;
                f_ToShow{j} = [sprintf('%03d', j) ' --> ' f_val{j}];
            end
        end
        f_list.String = f_ToShow; f_list.Value = 1;
        %---------------------
        
        fn = [folder '/' f_val{f_list.Value}];  % selected cdf data file name
        [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
        names = info.Variables(:, 1);  % list of all variables names
        text_f.String = [LoF_text int2str(length(names)) '.'];
        V_val = names; V_list.String = V_val; V_list.Value = 1;
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
     
        VV_val = data{V_list.Value};
        
        Get2Show();
        
        VV_list.String = ToShow; VV_list.Value = 1;
  end


  function Y_list_Callback(source, eventdata) 
      
        % List of days ------
        folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{source.Value}]; 
        D = dir(folder);     % list of all objects in current folder
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
        folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{source.Value} '/' D_val{D_list.Value}]; 
        df = dir(folder);     % list of all objects in current folder
        f_val = {}; j = 0; f_ToShow = {};
        for k = 1:length(df)
            if df(k).isdir==0
                j = j + 1;
                f_val{j} = df(k).name;
                f_ToShow{j} = [sprintf('%03d', j) ' --> ' f_val{j}];
            end
        end
        f_list.String = f_ToShow; f_list.Value = 1;
        %---------------------
        
        fn = [folder '/' f_val{f_list.Value}];  % selected cdf data file name
        [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
        names = info.Variables(:, 1);  % list of all variables names
        text_f.String = [LoF_text int2str(length(names)) '.'];
        V_val = names; V_list.String = V_val; V_list.Value = 1;
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
        
        VV_val = data{V_list.Value};
        
        Get2Show();
        
        VV_list.String = ToShow; VV_list.Value = 1;
  end


  function D_list_Callback(source, eventdata)
        
        % List of files -----
        folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{source.Value}]; 
        df = dir(folder);     % list of all objects in current folder
        f_val = {}; j = 0; f_ToShow = {};
        for k = 1:length(df)
            if df(k).isdir==0
                j = j + 1;
                f_val{j} = df(k).name;
                f_ToShow{j} = [sprintf('%03d', j) ' --> ' f_val{j}];
            end
        end
        f_list.String = f_ToShow; f_list.Value = 1;
        %---------------------
        
        fn = [folder '/' f_val{f_list.Value}];  % selected cdf data file name
        [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
        names = info.Variables(:, 1);  % list of all variables names
        text_f.String = [LoF_text int2str(length(names)) '.'];
        V_val = names; V_list.String = V_val; V_list.Value = 1;
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
        
        VV_val = data{V_list.Value};
        
        Get2Show();
        
        VV_list.String = ToShow; VV_list.Value = 1;
  end


  function f_list_Callback(source, eventdata)

        folder = [TargetDir '/' I_val{I_list.Value} '/cdf/' F_val{F_list.Value} '/' Y_val{Y_list.Value} '/' D_val{D_list.Value}]; 
        fn = [folder '/' f_val{source.Value}];  % selected cdf data file name
        [data, info] = spdfcdfread(fn, 'KeepEpochAsIs', 1); % read data and data info; this function closes the file itself
        names = info.Variables(:, 1);  % list of all variables names
        text_f.String = [LoF_text int2str(length(names)) '.'];
        V_val = names; V_list.String = V_val; V_list.Value = 1;
        VE_list.String = V_val; VE_list.Value = 1;
        
        S_val = {info.Variables{V_list.Value, 1};num2str(info.Variables{V_list.Value, 2});...
                 info.Variables{V_list.Value, 4}; num2str(info.Variables{V_list.Value, 9})};
        text_S.String = S_val;
        
        VV_val = data{V_list.Value};
        
        Get2Show();
        
        VV_list.String = ToShow; VV_list.Value = 1;
  end

  
  function V_list_Callback(source, eventdata)
        S_val = {info.Variables{source.Value, 1}; num2str(info.Variables{source.Value, 2});...
                 info.Variables{source.Value, 4}; num2str(info.Variables{source.Value, 9})};
        text_S.String = S_val; 
        
        VV_val = data{source.Value};
        
        Get2Show();

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

  function Get2Show();
        NN = size(VV_val, 1);        % number of triggers
        numers = [int2str([1:NN].') repmat('  -->  ', NN, 1)];
        
        if strcmp(S_val{3}, 'epoch16')
            temp = T0 + seconds(VV_val(:, 1) + VV_val(:, 2)*1e-12);      % raw contains read epoch16 data from cdf
            temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
            ToShow = [numers char(temp)];
        else
            if strcmp(S_val{3}, 'epoch')
                NN = length(VV_val);        % number of triggers
                numers = [int2str([1:NN].') repmat('  -->  ', NN, 1)];
                temp = T0 + seconds(VV_val*1e-3);      % raw contains read epoch16 data from cdf
                temp.Format = 'yyyy-MMM-dd HH:mm:ss.SSSSSS';
                ToShow = [numers char(temp)];    
            else
                if strcmp(S_val{3}, 'char')
                    ToShow = [numers VV_val];
                else
                    ToShow = VV_val(:, 1);
                end
            end
        end
        
        if strfind(S_val{3}, 'int')
            ToShow = [numers int2str(ToShow)];
        else
            if strfind(S_val{3}, 'double')
                ToShow = [numers num2str(ToShow)];
            end
        end
  end

%--------------------------------------------------------------------------

end