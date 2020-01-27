clc
clear
M = 11;
N = 26;
% CHECK OSCILLASCOPE CHANNEL BEFORE RUN!!
%%
for m = 1 : M
    for n = 1 : 3
        filename = strcat('M', num2str(m), '_', num2str(n), '.bin');
        [~, data2] = importAgilentBin(filename, 4);
        [data1, data5] = importAgilentBin(filename, 3);
        % Down sampling
        data1 = data1(1:100:end);
        data2 = data2(1:100:end);
        data5 = data5(1:100:end);
%         [dip_y, dip_x] = min(data5);
%         data1 = data1(dip_x+1e3:end-1e3);
%         data2 = data2(dip_x+1e3:end-1e3);
%         data5 = data5(dip_x+1e3:end-1e3);
        figure
        hold on
        plot(data2);
        plot(data5);
%         scatter(dip_x, dip_y);
        filename = strcat('M', num2str(m), '_', num2str(n), '.mat');
        save(filename, 'data1', 'data2', 'data5');
    end
    pause(1);
    close all
end
for m = 1 : N
    for n = 1 : 3
        filename = strcat('D', num2str(m), '_', num2str(n), '.bin');
        [~, data2] = importAgilentBin(filename, 4);
        [data1, data5] = importAgilentBin(filename, 3);
        data1 = data1(1:100:end);
        data2 = data2(1:100:end);
        data5 = data5(1:100:end);
%         [dip_y, dip_x] = min(data5);
%         data1 = data1(dip_x+1e3:end-1e3);
%         data2 = data2(dip_x+1e3:end-1e3);
%         data5 = data5(dip_x+1e3:end-1e3);
        figure
        hold on
        plot(data2);
        plot(data5);
%         scatter(dip_x, dip_y);
        filename = strcat('D', num2str(m), '_', num2str(n), '.mat');
        save(filename, 'data1', 'data2', 'data5');
    end
    pause(1);
    close all
end