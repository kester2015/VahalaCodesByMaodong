function [ Error ] = NFTLB6700_SetLambdaTrack( LambdaTrack )

Cmd = char([int8('OUTPut:TRACk ') int8(num2str(LambdaTrack)) int8(13) int8(10)]); 
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',1,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    Error = 0;
else 
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
    Error = 1;
end

end

