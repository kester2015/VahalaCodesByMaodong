function NIUSB6212_Close(DAQ,DAQInfo)

for ii=1:DAQInfo.NumCh
	delete(DAQ(ii));
end

end