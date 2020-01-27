function [] = NF6300_control(l)
% Find a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 32, 'PrimaryAddress', 10, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('AGILENT', 32, 10);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

% Communicating with instrument object, obj1.
% l = 1550;
query(obj1, ['WAVE ', num2str(l)]);
pause(3);
query(obj1, 'OUTP:TRAC OFF');

% Wait till complete
operationComplete = str2double(query(obj1,'*OPC?'));
while ~operationComplete
    operationComplete = str2double(query(obj1,'*OPC?'));
end