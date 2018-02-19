% compute poor share of income using PS paramters for lognormal dist.
%User needs to acquire the parameters of the log-normal from the authors of
%that paper or provide their own.
clear all;

%---------READ DATA-------------------
filename = 'PSInc2Matlab.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%f%f%f%f%[^\n\r]';

%% Open, read, and label
fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

countrycode = dataArray{:, 1};
Npoor = dataArray{:, 2};
PSIncD_mu = dataArray{:, 3};
PSIncD_sigma = dataArray{:, 4};


%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%---------Compute CDF of lnnormal-------------------

for i=1:size(Npoor)
 poorshare(i,1) = logninv(Npoor(i,1),PSIncD_mu(i,1),PSIncD_sigma(i,1))/logninv(0.99,PSIncD_mu(i,1),PSIncD_sigma(i,1));
end

sInc_rich = 1-poorshare;
A(:,1) = countrycode;
A(:,2) = sInc_rich;
csvwrite('sInc_Rich.csv',A)
