%% Loading Utility Information

%Removed xlsread routine, if any change made to rates, re-define saved variables

%% Electricity rates
%%%Load SCE Energy Costs

%%%Comercial/Industrial Rates
%[erates_ci,labels] = xlsread('SCE_CI.xlsx','Model Input');
load erates_ci ; load labels_ci

for i=1:size(erates_ci,2)
    erate_ci(:,i) = erates_ci(2:6,i) + erates_ci(1,i); % Adding T&D to all rates 
end

%%%Rate Labeling
rate_labels=labels(2,2:size(labels,2));

%%%Demand Charges
dc_nontou = erates_ci(7,:);
dc_on = erates_ci(8,:);
dc_mid = erates_ci(9,:);

%%%NBC for C/I
nbc_ci = erates_ci(end,:);

%%%TOU for C/I Rates (hours at which rates switch)
tou_winter=[8;13;3];
tou_winter=[8  21];
tou_summer=[8;4;6;5;1];
tou_summer=[8 12 18 23];

%%%Residential Rates
%[erates_d,labels] = xlsread('SCE_D_TOU.xlsx','Model Inputs');
load erates_d ; load labels
rate_labels=[rate_labels labels(2,2:size(labels,2))];

%%%Typical TOU Rates (A & B)
erates_d_tou = erates_d(:,1:2);
nbc_d_tou = erates_d(end,1:2);

d_tou_week = [8 14 20 22];
d_tou_weekend = [8 22];

%%%Nontypical TOU Rates (PM rates)
erates_d_tou_pm = erates_d(:,3:4);
nbc_d_tou_pm = erates_d(end,3:4);
d_pm_tou = [16 21; 17 20];

% %%%Residectial TOU AB
% [erates_d_tou,labels] = xlsread('SCE_R_TOU.xlsx','AB');
% d_tou_week = [8 14 20 22]
% d_tou_weekend = [8 22];

% [erates_d_tou_pm,labels] = xlsread('SCE_R_TOU.xlsx','PM');
% rate_labels=[rate_labels labels(2,2:size(labels,2))]
% d_pm_tou = [16 21; 17 20];

%%%Normal Residential Rates
% erates_d = xlsread('SCE_D.xlsx');

% erates_d = [erates_d(1:3,:) + erates_d(4:6,:)
%     erates_d(1:3,:) + erates_d(7:9,:)]

% ratedata = xlsread('SCE_Rate_Matrix.xlsx','GS8');

%%% Wholesale export rate, Net Surplus Compensation Rate ($/kWh)
ex_wholesale = 0.03;

%%%Loading CO2 emission rates associated with the grid
load('co2_rates_example.mat');
co2_rates=co2_rates.*(0.650/mean(co2_rates));
grid_emissions(:,1)=co2_rates;

