function yy = ReadEGG5110LockinMAG_avg(Lockin13,avg,interval)
tpower = zeros(1,avg);
for kk = 1:length(tpower)
    tpower(kk) = ReadEGG5110LockinMAG(Lockin13);
    pause(interval);
end
yy = mean(tpower);
end