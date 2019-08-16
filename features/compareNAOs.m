
%% 0. settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'functions']), genpath(['..' f 'data' f 'nao']));

%% NAO data preparation
% general settings
truncate = 1979;
extractMonths = [12 1 2];
extractNegPos = false;

%% already calculated naos downloaded from NOAA/CRU
% for details of the different files have a look at 'nao_overview.ods'
% settings
folderName = 'NOAA_CRU_already calculated';
reshape_1 = true;
replace_1 = -99.99;

% NOAA monthly
[~,~,nao_1_wint] = prepareNAOs([folderName f 'nao_1.data'],...
    reshape_1,replace_1,truncate, extractMonths,extractNegPos);
% CRU monthly
[~,~,nao_2_wint] = prepareNAOs([folderName f 'nao_2.data'],...
    reshape_1,replace_1,truncate, extractMonths,extractNegPos);

%% computed as pressure differences with data from ERA5
% settings
folderName = 'ERA5';
reshape_2 = false;
replace_2 = [];

[~,~,nao_ERA5_wint] = prepareNAOs([folderName f 'diffNAO_ERA5.mat'],...
    reshape_2,replace_2,truncate, extractMonths,extractNegPos);

%% computed as pressure differences with data from CMIP6 - historical
% settings
folderName = 'CMIP6_psl historical';
reshape_3 = false;
replace_3 = [];

path = 'C:\Users\Lenovo\Documents\Master\DMI-north_atlantic_oscillation\data\nao\CMIP6_psl historical\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    [~,~,nao_CMIP6_historical{i}] = prepareNAOs(strcat(path,folderContents(i).name),...
        reshape_3,replace_3,truncate, extractMonths,extractNegPos);
    nao_CMIP6_historical{i}.name = strrep(folderContents(i).name,'_',' ');
end

%% NAO data plots
% axis definitions
ax_1 = nao_1_wint.time;
ax_2 = nao_2_wint.time;
ax_era5 = nao_ERA5_wint.time;

for k = 1 : length(nao_CMIP6_historical)
    ax_CMIP6_hist{k} = nao_CMIP6_historical{k}.time;
end

%% fitered
a = 1;
% windows size for monthly data
ws = 3; % average of 3 values
b = (1/ws)*ones(1,ws);

% compute filtered time series
nao_1_filt = filter(b,a,nao_1_wint.nao);
nao_2_filt = filter(b,a,nao_2_wint.nao);
nao_era5_filt = filter(b,a,nao_ERA5_wint.nao);
for k = 1 : length(nao_CMIP6_historical)
    nao_CMIP6_hist_filt{k} = filter(b,a, nao_CMIP6_historical{k}.nao);
end

% plots
lw = 2; % LineWidth
% --- part 1 ---
figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
plot(ax_1,nao_1_filt,'LineWidth',lw);
plot(ax_2,nao_2_filt,'LineWidth',lw);
plot(ax_era5,nao_era5_filt,'LineWidth',lw);

for k = 1 : 5
    plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','LineWidth',1.2);
end

hold off;
title(['NAO data comparison, DJF, filtered, windows size: ' num2str(ws)]);
legend('NOAA monthly', 'CRU monthly', 'from ERA5 pressure differences',...
    ['from ' nao_CMIP6_historical{1}.name ' pressure differences'],...
    ['from ' nao_CMIP6_historical{2}.name ' pressure differences'],...
    ['from ' nao_CMIP6_historical{3}.name ' pressure differences'],...
    ['from ' nao_CMIP6_historical{4}.name ' pressure differences'],...
    ['from ' nao_CMIP6_historical{5}.name ' pressure differences']);

% --- part 2 ---

figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
plot(ax_1,nao_1_filt,'LineWidth',lw);
plot(ax_2,nao_2_filt,'LineWidth',lw);
plot(ax_era5,nao_era5_filt,'LineWidth',lw);

for k = 6 : length(nao_CMIP6_historical)
    plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','LineWidth',1.2);
end

hold off;
title(['NAO data comparison, DJF, filtered, windows size: ' num2str(ws)]);
legend('NOAA monthly', 'CRU monthly', 'from ERA5 pressure differences',...
    ['from ' nao_CMIP6_historical{6}.name ' pressure differences'],...
    ['from ' nao_CMIP6_historical{7}.name ' pressure differences'],...
    ['from ' nao_CMIP6_historical{8}.name ' pressure differences'],...
    ['from ' nao_CMIP6_historical{9}.name ' pressure differences'],...
    ['from ' nao_CMIP6_historical{10}.name ' pressure differences']);

