function pwrmtr = OpenThorPowerMeter
% Open the Thor USB-based power meter
% D.E. Leaird, 9-Sep-12
%  Example call:  device = OpenThorPowerMeter   % Use device in subsequent
%  calls.
%  Remember to close the device w/ fclose(device) / clear device when done
pwrmtr = visa('ni','USB0::0x1313::0x8079::P1002155::INSTR');
fopen(pwrmtr);
return