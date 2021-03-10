

DataSet = AgilentVNA_SingleSweep(16, 4, 300e3, 20e9, 300, 801, 10e-6);


subplot(2,1,1);
hold on;
plot(DataSet(:,1)./1e9,DataSet(:,2),'r')            %Plot the Magnitude
xlabel('Frequency (GHz)')
ylabel('S21 (dB)')
subplot(2,1,2);
hold on;
plot(DataSet(:,1)./1e9,DataSet(:,3),'r')            %Plot the Magnitude
xlabel('Frequency (GHz)')
ylabel('Phase (rad)')
%%