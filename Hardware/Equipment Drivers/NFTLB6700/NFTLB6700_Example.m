%%
% Te values used in this example are in the wavelength range of the
% New Focus Laser in room SB010

%% Open
[TLB TLBInfo ] = NFTLB6700_Open();
% Check the DeviceID of the laser you want to configure in the Info string.

%% Set 
NFTLB6700_SetWavelength(TLB, 1540);
NFTLB6700_SetLambdaTrack(TLB, 1);
NFTLB6700_SetOutputEnable(TLB, 1);

%% Scan Example
ScanParams.StartWavelength = 770;
ScanParams.StopWavelength = 775;
ScanParams.ForwardSpeed = 1;
ScanParams.ReturnSpeed = 10;
ScanParams.NumScans = 1;
ScanParams.ReduceReturnPower = 0;
NFTLB6700_Scan(TLB, ScanParams);

%% Scan with wavelength measurement
Scan.StartWavelength = 770;
Scan.StopWavelength = 771;
Scan.ForwardSpeed = 0.01;
Scan.ReturnSpeed = 8;
Scan.NumScans = 1;
Scan.ReduceReturnPower = 0;
NFTLB6700_Scan(DeviceID, Scan);

N = 10000;
Wavelength = zeros(1,N);
% Power = zeros(1,N);
for ii=1:N
    Wavelength(ii) = NFTLB6700_SenseWavelength(TLB);
%     fprintf(pwrmtr,'READ?'); 
%     Power(ii) = str2double(fscanf(pwrmtr));
end

%% Close
NFTLB6700_Close;