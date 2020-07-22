

clear
clc

filename = 'C:\Users\Lab\Documents\Maodong\20200721\disper\Dev21\pol1-1520-1570nm.mat';
load(filename);

data_old = data_matrix(:,2);
data_freq = fft(data_old);

figure;
plot(abs(data_freq));

substart = input('subsitution frequency domain starts at:');%150;
subend = input('subsitution frequency domain ends at:');%1500;
data_freq_new = data_freq;
data_freq_new(substart:subend) = data_freq(subend:2*subend-substart);
data_freq_new(end-subend:end-substart)=data_freq(end-2*subend+substart:end-subend);


hold on
plot(abs(data_freq_new));
title('old and new data freq domain');


data_new = abs(ifft(data_freq_new));
data_matrix(:,2)=data_new;

figure;
plot(data_old);
hold on
plot(data_new);
title('old and new data compare');



newfilename = split(filename,'\');
newfilename{end} = ['filted-' newfilename{end}];
newfilename = join(newfilename,'\');
newfilename = newfilename{1};
if isfile(newfilename)
    ii = 2;
    while isfile(newfilename)
        newfilename = split(filename,'\');
        newfilename{end} = ['filted' num2str(ii) '-' newfilename{end}];
        newfilename = join(newfilename,'\');
        newfilename = newfilename{1};
        ii = ii+1;
    end
    save(newfilename,'data_matrix');
else
    save(newfilename,'data_matrix');
end
