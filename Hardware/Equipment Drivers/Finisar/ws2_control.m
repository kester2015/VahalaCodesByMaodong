device_ws1 = OpenFinisar3('WS1');

%%port number
port=1;


%%
freq_s = 187.275e12;
freq_e = 196.275e12;
dim = 9000;          % Number of pixels on Finisar.

%% band pass
lbp = [1530,1610]-0.8;
pix_lbp = wav2pix_ws2(lbp);
%pix_lbp = round(P(1)*lbp.^2+P(2)*lbp+P(3));

phase_array = zeros(dim,1);
amplitude_array = 60*ones(dim,1);
output_port_array = port*ones(dim,1);
amplitude_array(pix_lbp(2):pix_lbp(1)) = 0;
WriteFinisar3(device_ws1,amplitude_array,phase_array,output_port_array);

%% by pass
lbp = [1556.1743];
%lbp+0.12 +0.001 % +0.0024 offset

pix_lbp = wav2pix_ws1(lbp);
          

phase_array = zeros(dim,1);
amplitude_array = 60*ones(dim,1);
output_port_array = 1*ones(dim,1);

amplitude_array(pix_lbp-17:end) = 0;

%% band reject
dim=5025;
lbj1 = 1550; % starting wavelength of band rejection
lbj2 = 1552; % end wavelength of band rejection
%lbp+0.12 +0.001 % +0.0024 offset

pix_lbj1 = round(wav2pix_ws1(lbj1));
pix_lbj2 = round(wav2pix_ws1(lbj2));
          

phase_array = zeros(dim,1);
amplitude_array = 0*ones(dim,1);
output_port_array = 1*ones(dim,1);

amplitude_array(pix_lbj2:pix_lbj1) = 60;  % reject the lines
WriteFinisar3(device_ws1,amplitude_array,phase_array,output_port_array);

%% all through
phase_array = zeros(dim,1);
amplitude_array = 0*ones(dim,1);
output_port_array = port*ones(dim,1);

%% all block
phase_array = zeros(dim,1);
amplitude_array = 60*ones(dim,1);
output_port_array = port*ones(dim,1);

%% band pass for breather experiments
lbp = [1530,1536]-0.8;
pix_lbp = wav2pix_ws2(lbp);
%pix_lbp = round(P(1)*lbp.^2+P(2)*lbp+P(3));

phase_array = zeros(dim,1);
amplitude_array = 60*ones(dim,1);
output_port_array = port*ones(dim,1);
amplitude_array(pix_lbp(2):pix_lbp(1)) = 0;
WriteFinisar3(device_ws1,amplitude_array,phase_array,output_port_array);
%%
WriteFinisar3(device_ws1,amplitude_array,phase_array,output_port_array);

%%
CloseFinisar3(device_ws1,1);

