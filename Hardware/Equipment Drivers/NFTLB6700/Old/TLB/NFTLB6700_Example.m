%%
% Te values used in this example are in the wavelength range of the
% New Focus Laser in room SB010

%% Open
Info = NFTLB6700_Open;
% Check the DeviceID of the laser you want to configure in the Info string.
DeviceID = 1;

%% Set 
NFTLB6700_SetWavelength(DeviceID, 1540);
NFTLB6700_SetLambdaTrack(DeviceID, 1);

%% Scan Example
ScanParams.StartWavelength = 1540;
ScanParams.StopWavelength = 1545;
ScanParams.ForwardSpeed = 1;
ScanParams.ReturnSpeed = 8;
ScanParams.NumScans = 1;
ScanParams.ReduceReturnPower = 0;
NFTLB6700_Scan(DeviceID, ScanParams);

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
 Power = zeros(1,N);
for ii=1:N
    Wavelength(ii) = NFTLB6700_SenseWavelength(DeviceID);
     fprintf(pwrmtr,'READ?'); 
     Power(ii) = str2double(fscanf(pwrmtr));
end

%% Close
NFTLB6700_Close;