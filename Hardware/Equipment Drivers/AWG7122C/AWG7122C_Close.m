function AWG7122C_Close(AWG)
% Close Tektronics Arbitrary Waveform Generator AWG7122C

fclose(AWG);
delete(AWG);