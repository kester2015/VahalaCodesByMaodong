function [Position Error] = VOADD600MC_GetPosition(VOA)

fprintf(VOA,'D');
StrAnsA = fscanf(VOA);
StrAnsB = fscanf(VOA);
StrAnsC = fscanf(VOA);
StrAnsD = fscanf(VOA);


Position = str2double(StrAnsA(6:end));
if strcmp(StrAnsC,char([10   68  111  110  101   13]))
    Error = 0;
else
    Error = 1;
end

end
