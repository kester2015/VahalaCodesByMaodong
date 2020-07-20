
close all
clear
clc


load('Z:\Maodong\20200216\coupling\1562.2nm_882.6MHz.mat')
X = X(1:100:end);
Y = Y(1:100:end,:);
Y(:,3) = Y(:,3)/50;
figure;
for ii = 2:4
    plot(X,Y(:,ii));
    hold on
end
title("1562nm")