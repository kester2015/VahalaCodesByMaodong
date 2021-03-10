%% Open
% Open Laser
Info = NFTLB6700_Open;
DeviceID = 1;
% Open Power Meter
pwrmtr = visa('ni','USB0::0x1313::0x8079::P1001138::INSTR');
fopen(pwrmtr);

%% Scan wavelength measure power

Scan.StartWavelength = 765;
Scan.StopWavelength = 781;
Scan.ForwardSpeed = 1;
Scan.ReturnSpeed = 8;
Scan.NumScans = 1;
Scan.ReduceReturnPower = 0;
NFTLB6700_Scan(DeviceID, Scan);

N = 800;
Wavelength = zeros(1,N);
Power = zeros(1,N);
tid = tic;
tic;
for ii=1:N
    Wavelength(ii) = NFTLB6700_SenseWavelength(DeviceID);
    fprintf(pwrmtr,'READ?'); 
    Power(ii) = str2double(fscanf(pwrmtr));
    while toc < 0.02
    end
    tic;
end
t = toc(tid);
plot(Wavelength,Power)
save('PPLN_S02_W08_201404101628','Wavelength','Power')

%% Close
NFTLB6700_Close;
fclose(pwrmtr);
delete(pwrmtr);
clear pwrmtr;