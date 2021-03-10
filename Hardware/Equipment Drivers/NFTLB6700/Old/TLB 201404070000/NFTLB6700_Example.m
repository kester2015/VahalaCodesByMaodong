%% Open
NFTLB6700_Open;

%% Set 
NFTLB6700_SetWavelength(772.54);
NFTLB6700_SetLambdaTrack(1);

%% Scan Example
Scan.StartWavelength = 770;
Scan.StopWavelength = 775;
Scan.ForwardSpeed = 1;
Scan.ReturnSpeed = 1;
Scan.NumScans = 2;
Scan.ReduceReturnPower = 0;
NFTLB6700_Scan(Scan);

%% Close
NFTLB6700_Close;