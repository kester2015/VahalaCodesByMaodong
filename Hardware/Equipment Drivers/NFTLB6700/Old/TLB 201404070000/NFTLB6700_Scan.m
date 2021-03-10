function [ Error ] = NFTLB6700_Scan( Scan )

NFTLB6700_SetScanStartWavelength( Scan.StartWavelength )
NFTLB6700_SetScanStopWavelength( Scan.StopWavelength )
NFTLB6700_SetScanForwardSpeed( Scan.ForwardSpeed )
NFTLB6700_SetScanReturnSpeed( Scan.ReturnSpeed )
NFTLB6700_SetScanNumScans( Scan.NumScans )
NFTLB6700_SetScanReduceReturnPower( Scan.ReduceReturnPower )

Cmd = char([int8('OUTPut:SCAN:START') int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',1,Cmd,length(Cmd));
if ~strcmp(Cmd,CmdAck)
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end

    
end

