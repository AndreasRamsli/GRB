function extract_data(fn)
    load(fn);
    N = length(Data.TCP);
    tcp = [];
    tus = [];
    dau = [];
    det = [];
    typ = [];
    erg = [];
    for k = 1:N
        tcp(end+1) = Data.TCP(k).TCP;
        tus = [tus; 1e6*tcp(k)+Data.TCP(k).BGO.tus];
        dau = [dau; Data.TCP(k).BGO.dau];
        det = [det; Data.TCP(k).BGO.det];
        typ = [typ; Data.TCP(k).BGO.typ];
        erg = [erg; Data.TCP(k).BGO.erg];
    end
    data = [tus, dau, det, typ, erg];
    column_names = {'tus', 'dau', 'det', 'typ', 'erg'};
    T = table(data(:,1), data(:,2), data(:,3), data(:,4), data(:,5), 'VariableNames', column_names);
    writetable(T, strcat(fn,'.csv'));
end


