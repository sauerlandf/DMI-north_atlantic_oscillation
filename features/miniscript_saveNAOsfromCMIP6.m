
%% settings
clearvars; close all; clc;
addpath(genpath(cd), genpath(['..' filesep 'data' filesep 'nao']),...
    genpath(['..' filesep 'functions']));

%% load/save paths
% [file, path] = uigetfile({'*.mat', 'MATLAB binary file (*.mat)'}, 'Please select one file to read. All files will be added automatically');
file = 'psl_Amon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn.mat';
path = 'D:\cmip6\psl_NAO_EOF_historical\mat-files\';
folderContents = dir(strcat(path, '*.mat'));

% [~, s_path] = uiputfile({'.mat', 'MATLAB binary file (*.mat)'}, 'Save plots as...');
s_path = 'D:\cmip6\psl_NAO_EOF_historical\mat-files\NAOs from pressure differences\';

%% load, compute NAO, save
for i = 1:size(folderContents, 1)
    load(strcat(path,folderContents(i).name));    
    nao_temp = compute_NAO(data);
    nao = struct('time',data.time);
    nao = setfield(nao,'nao',nao_temp);
    save(strcat(s_path, 'diffNAO_', folderContents(i).name),'nao');
end

