function hh = plotOSCTraces(filename)
    load(filename);
    if length(timeAxis) > 1e4
        timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
        Ch3= Ch3(1:round(length(Ch3)/1e4):end);
        Ch2 = Ch2(1:round(length(Ch2)/1e4):end);
        Ch1= Ch1(1:round(length(Ch1)/1e4):end);
        Ch4 = Ch4(1:round(length(Ch4)/1e4):end);
    end
    hh = figure;
    plot(timeAxis,Ch1);
    hold on
    plot(timeAxis,Ch2);
    hold on
    plot(timeAxis,Ch3);
    hold on
    plot(timeAxis,Ch4);
    hold on
    legend({'Ch1','Ch2','Ch3','Ch4'});
    xlabel('Time/s');
    ylabel('Voltage/V');
end