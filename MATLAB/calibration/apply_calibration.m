
%%
% output is energy in keV
function energies = apply_calibration(time,channels)
    global mydatetimes;
    global coefs;
    
    coefs=double(coefs);
    
    if time>min(mydatetimes)
        a_coef = interp1(mydatetimes,coefs(:,1),time);
        b_coef = interp1(mydatetimes,coefs(:,2),time);
        c_coef = interp1(mydatetimes,coefs(:,3),time);
    else
        disp('warning: time is below minimal time of calibration data. Using the smallest available time')
        disp(time)
        a_coef = interp1(mydatetimes,coefs(:,1),min(mydatetimes));
        b_coef = interp1(mydatetimes,coefs(:,2),min(mydatetimes));
        c_coef = interp1(mydatetimes,coefs(:,3),min(mydatetimes));
    end
    
    if time>max(mydatetimes)
        disp('warning: time is above maximal time of calibration data.')
    end
    
    channels=double(channels);
    
    energies = a_coef .* channels.^2 + b_coef .* channels + c_coef;
    
    end


