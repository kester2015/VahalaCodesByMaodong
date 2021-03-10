%% Open
Info = NFTLB6700_Open;
pwrmtr = visa('ni','USB0::0x1313::0x8079::P1001138::INSTR');
fopen(pwrmtr);

%%
% StartWl = 765;
% StopWl = 781;
% StepWl = 0.01;
% 
% Wl = StartWl:StepWl:StopWl;
% N = size(Wl,2);
% Power = zeros(1,N);
% for ii=1:N
%     NFTLB6700_SetWavelength(Wl(ii));
%     pause(0.1);
%     fprintf(pwrmtr,'READ?');
%     Power(ii) = eval(fscanf(pwrmtr));
% end

%%
Scan.StartWavelength = 765;
Scan.StopWavelength = 781;
Scan.ForwardSpeed = 0.01;
Scan.ReturnSpeed = 8;
Scan.NumScans = 1;
Scan.ReduceReturnPower = 0;
NFTLB6700_Scan(Scan);

N = 200;
Wavelength = zeros(1,N);
Power = zeros(1,N);
for ii=1:N
    Wavelength(ii) = NFTLB6700_SenseWavelength();
    fprintf(pwrmtr,'READ?'); 
    Power(ii) = str2double(fscanf(pwrmtr));
end



%% Close
NFTLB6700_Close;
fclose(pwrmtr);
delete(pwrmtr);
clear pwrmtr;