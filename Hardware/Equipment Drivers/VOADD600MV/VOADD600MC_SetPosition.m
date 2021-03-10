function [Error] = VOADD600MC_SetPosition(VOA,Position)

fprintf(VOA,['S' num2str(Position)]);
StrAnsA = fscanf(VOA);
StrAnsB = fscanf(VOA);
StrAnsC = fscanf(VOA);

if strcmp(StrAnsB,char([10   68  111  110  101   13]))
    Error = 0;
else
    Error = 1;
end

end
