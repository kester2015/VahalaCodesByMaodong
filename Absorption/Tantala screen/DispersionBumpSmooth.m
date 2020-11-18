clear
clc

filename = 'Z:\Qifan\LN\20201024\No.-2\disper\filted--1520-1570nm.mat';
load(filename);

data_old = data_matrix(:,2);


filted = sgolayfilt(data_old,2,round(length(data_matrix(:,2)))*0.001+1);

filted = sgolayfilt(filted,2,round(length(data_matrix(:,2)))*0.001+1);

filted = sgolayfilt(filted,2,round(length(data_matrix(:,2)))*0.001+1);




data_new = min(data_old,filted);

data_matrix(:,2)=data_new;
newfilename = split(filename,'\');
plotTitle = newfilename{end};
newfilename{end} = ['BumpSmoothed-' newfilename{end}];
newfilename = join(newfilename,'\');
newfilename = newfilename{1};
if isfile(newfilename)
    ii = 2;
    while isfile(newfilename)
        newfilename = split(filename,'\');
        newfilename{end} = ['BumpSmoothed-' num2str(ii) '-' newfilename{end}];
        plotTitle = newfilename{end};
        newfilename = join(newfilename,'\');
        newfilename = newfilename{1};
        ii = ii+1;
    end
    save(newfilename,'data_matrix');
else
    save(newfilename,'data_matrix');
end