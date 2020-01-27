function log=VVFzMap(log,handles,nIndex,bBoundry,CurrentEDFAPower)
PDPower=str2double(handles.edit4.String)*1e-3;
if isnan(PDPower)
    error('Invalid PD Power.');
end
InitialPower=PDPower*log.PDPowerCorrectionRatio; % mW in taper
if nargin<4
    bBoundry=false;
end
if nargin<5
    CurrentEDFAPower=0;
end
if bBoundry
    try
        log.FzLowerBoundry(nIndex,1)=log.StateFz(nIndex,1);
        log.FzLowerBoundry(nIndex,2)=log.VVFzMap.NormalizePowerFromVoltage(InitialPower,log.VaomLowerBoundry(nIndex,2)); % normalized power F^2
    catch
    end
    
    try
        log.FzUpperBoundry(nIndex,1)=log.StateFz(nIndex,1);
        log.FzUpperBoundry(nIndex,2)=log.VVFzMap.NormalizePowerFromVoltage(InitialPower,log.VaomUpperBoundry(nIndex,2)); % normalized power F^2
    catch
    end
else
    if CurrentEDFAPower==0
        log.StateFz(nIndex,2)=log.VVFzMap.NormalizePowerFromVoltage(InitialPower,log.StateVV(nIndex,2)); % normalized power F^2
    else
        % set default value (need manually input PD power)
        log.StateFz(nIndex,2)=20;
    end
    log.StateFz(nIndex,1)=log.VVFzMap.NormalizeDetuning(log.fdetuning(nIndex));
end
end