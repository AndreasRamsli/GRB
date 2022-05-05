%%
function load_calibration(i_dau,i_det)
global mydatetimes;
global coefs;

calib_file = ['calibration_coefficients_dau_' num2str(i_dau) '_det_' num2str(i_det) '.txt'];

fid = fopen(calib_file,'r');

tline = fgetl(fid);

mydatetimes=NaT(0,0);
coefs=[];

while ischar(tline)
    tline = fgetl(fid);
    
    if tline==-1
        continue
    end
    
    if contains(tline,'DATE        TIME')
        continue
    end
    
    if contains(tline,'                                               ')
        continue
    end
    
    if length(tline)>51
        mydatetime_str = tline(1:20);
        mydatetimes(end+1) = datetime(mydatetime_str);
        coefs(end+1,:)=str2num(tline(21:end));
    end
end
fclose(fid);


end
