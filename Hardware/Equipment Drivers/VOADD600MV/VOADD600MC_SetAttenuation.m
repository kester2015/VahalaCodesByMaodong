function [Error] = VOADD600MC_SetAttenuation(VOA,Attenuation)

fprintf(VOA,['A' num2str(Attenuation)]);
StrAnsA = fscanf(VOA);
StrAnsB = fscanf(VOA);
StrAnsC = fscanf(VOA);

if strcmp(StrAnsB,char([10   68  111  110  101   13]))
    Error = 0;
else
    Error = 1;
end

end
