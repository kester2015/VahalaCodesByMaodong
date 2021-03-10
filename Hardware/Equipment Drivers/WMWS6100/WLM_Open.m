function [TLB TLBInfo] = WLM_Open()
if ~libisloaded('wlmData')
    loadlibrary('wlmData.dll','wlmData.hml')
    TLBInfo.Type = calllib('wlmData','GetWLMVersion',0);
    TLBInfo.Version = calllib('wlmData','GetWLMVersion',1);
    TLBInfo.Revision = calllib('wlmData','GetWLMVersion',2);
else 
    TLBInfo = '';
end
TLB = 1;