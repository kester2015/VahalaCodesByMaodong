%% Open
Info = NFTLB6700_Open;
% Check the DeviceID of the laser you want to configure in the Info string.
DeviceID = 1;

%% Set 
NFTLB6700_SetWavelength(DeviceID, 772.54);
NFTLB6700_SetLambdaTrack(DeviceID, 1);

%% Scan Example
ScanParams.StartWavelength = 770;
ScanParams.StopWavelength = 775;
ScanParams.ForwardSpeed = 1;
ScanParams.ReturnSpeed = 1;
ScanParams.NumScans = 2;
ScanParams.ReduceReturnPower = 0;
NFTLB6700_Scan(DeviceID, ScanParams);

%% Sense example
CurrentWavelength = NFTLB6700_SenseWavelength(DeviceID);

%% Close
NFTLB6700_Close;