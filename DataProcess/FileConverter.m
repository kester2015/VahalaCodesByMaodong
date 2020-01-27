function data = FileConverter(filename,type)
switch type
    case {'OSA'} % OSA file
        if numel(filename) > 4 && strcmpi(filename(end-3:end),'.CSV')
            filename = filename(1:end-4); % remove extension
        end
        data = csvread([filename '.CSV'],34,0);
        plot(data(:,1),data(:,2));
        xlabel('Wavelength (nm)');
        ylabel('Power (dBm)');
        xlim([data(1,1) data(end,1)])
        ylim([-80 -10])
    case {'RF'} % RF beat note
        data = dlmread(filename,';',27,0);
        data = data(:,1:2);
        data(:,1) = data(:,1)/1e6;
        center = mean(data(:,1));
        plot(data(:,1) - center,data(:,2));
        xlabel(sprintf('Frequency (MHz + %.2f MHz)',center));
        ylabel('Power (dBm)');
        xlim([data(1,1) data(end,1)] - center)
        ylim([-130 -10])
    case {'PN'} % Phase Noise
        data = dlmread(filename,';',222,0);
        data = data(:,1:2);
        semilogx(data(:,1),data(:,2));
        grid on
        xlabel('Frequency (Hz)');
        ylabel('Phase noise (dBc/Hz)');
        xlim([0 data(end,1)]);
        ylim([-120 3])
    case {'FN'} % Frequency Noise from UCSB
        data = dlmread(filename,'\t',12,0);
        data = data(:,[1,4]);
        loglog(data(:,1),data(:,2));
        grid on
        xlabel('Frequency (Hz)');
        ylabel('Frequency Noise (Hz^2/Hz)');
end
saveas(gca,[filename '.png']);
saveas(gca,[filename '.fig']);
save([filename '.mat'],'data');