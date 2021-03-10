
%% Open Device
[VOA, VOAInfo] = VOADD600MC_Open();

%% Set Attenuation
Error = VOADD600MC_SetAttenuation(VOA,10);

%%% Get Attenuation
[Att, Error] = VOADD600MC_GetAttenuation(VOA)

%% Set Position
Error = VOADD600MC_SetPosition(VOA,7000);

%%% Get Position
[Position, Error] = VOADD600MC_GetPosition(VOA)

%% Close Device
VOADD600MC_Close(VOA);
clear VOA VOAInfo;
