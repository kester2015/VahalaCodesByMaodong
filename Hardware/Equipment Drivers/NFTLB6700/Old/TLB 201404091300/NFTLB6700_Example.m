%%
% Te values used in this example are in the wavelength range of the
% New Focus Laser in room SB010

%% Open
Info = NFTLB6700_Open;
% Check the DeviceID of the laser you want to configure in the Info string.
DeviceID = 1;

%% Set 
NFTLB6700_SetWavelength(DeviceID, 772.38);
NFTLB6700_SetLambdaTrack(DeviceID, 1);

%% Scan Example
ScanParams.StartWavelength = 770;
ScanParams.StopWavelength = 775;
ScanParams.ForwardSpeed = 1;
ScanParams.ReturnSpeed = 8;
ScanParams.NumScans = 1;
ScanParams.ReduceReturnPower = 0;
NFTLB6700_Scan(DeviceID, ScanParams);

%% Close
NFTLB6700_Close;