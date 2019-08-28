
%%Days to be selected from building load
% summer_days=[22 8];
% summer_weekend_start=5;
% winter_days=[43 18];
% winter_weekend_start=3;
  
%% IEEE-33 node test case
%%% 11 representative loads

%Read all excel files in the "FilteredCleanData" folder
D = dir(['U:\Github\DERopt_inverter\FilteredCleanData', '\*.xlsx']);
filenames = {D(:).name}.';
%data = cell(length(D),1);
elec = zeros(8760,length(D));
for ii = 1:length(D)
      % Create the full file name and partial filename
      fullname = ['U:\Github\DERopt_inverter\FilteredCleanData\' D(ii).name];
      % Read in the data
      %data{ii} = xlsread(fullname); %If you just want to save the excel data in a cell
      elec(:,ii) = xlsread(fullname); %Builds elec vector. Buildings are assigned as they are ordered in the folder (alphabetical)
end

K = size(elec,2);
T = size(elec,1);

%% Date vector
%Artificially creating a time vector for 01-Jan-2008 00:00:00 to 31-Dec-2008 23:00:00 
time = datetime(2008,1,1,0,0,0):hours(1):datetime(2008,12,31,23,0,0); 
time(month(time) == 2 & day(time) == 29) =[]; %remove Feb 29th to make elec and time length to be 8760
datetimev=datevec(time);
time = datenum(datetimev); %okay I know this is weird but just a quick fix

% figure
% plot(elec)

%% Simulation time step:
t_step=round((time(2) - time(1))*(60*24));

%% Solar data
%load 'solar_m2.mat'
load 'solar_sna.mat'

%% K-medoids 

kmedoids_demand_mpc
kmedoids_solar_mpc

elec = elecsample;
solar = solarsample;
time = timesample;

% if filter_yr_2_day == 1
%     %%% Reducing demand to a subset of demand
%     yrly_8760_to_864
%     
%     %%%Using filter time
%     elec=elec_filtered;
%     time=time_filter;
%     solar=solar_filter;
%     
%     %%%Date vectors for all time stamps
%     datetimev=datevec(time);
%     %%%Determining endpoints for all months - end pt is the data entry for a month
%     counter=1;
%     for i=2:length(time)
%         if datetimev(i,2)~=datetimev(i-1,2)
%             endpts(counter,1)=i-1;
%             counter=counter+1;
%         end
%     end
%     
%     endpts(end)=length(time);
%     
% else
%     day_multi=ones(length(elec),1);
% end


%% Endpoints for all months - endpt is the hour index corresponding to the end of a month
counter=1;
for i=2:length(time)
    if datetimev(i,2)~=datetimev(i-1,2)
        endpts(counter,1)=i-1;
        counter=counter+1;
    end
end

%If spans one month only
if ~(exist('endpts'))
    endpts = length(elec);
end

%% Number of days in the simulation
day_count=1;
for i=2:size(datetimev,1)
    if datetimev(i-1,3)~=datetimev(i,3)
        day_count=day_count+1;
    end
end
%% Locating Summer Months
summer_month=[];
counter=1;
counter1=1;
% endpts
if length(endpts)>1
    for i=2:endpts(length(endpts))
        if datetimev(i,2)~=datetimev(i-1,2)
            counter=counter+1;
            if datetimev(i,2)>=6&&datetimev(i,2)<10
                summer_month(counter1,1)=counter;
                counter1=counter1+1;
            end
        end
    end
else
    if datetimev(1,2)>=6&&datetimev(1,2)<10
        summer_month=counter;
    end
end

%% Load Allocation for the IEEE-33 bus 
%recreating elec vector -> each column is one building (from previous elec) to be used in the IEEE-33 test case, multiplied by the scaling factor

%(1,K)
multiplier = [0.31	0.52	0.2	0.19	0.08	0.26	0.33	0.24	0.1	0.05	0.13	0.03	0.08	0.04	0.036	0.021	0.054	0.11	0.093	0.041	0.047	0.061	0.45	0.073	0.082	0.26	0.065	0.114	0.061	0.054	0.075	0.054	0.123	0.02	0.1	0.32	0.29	0.255	0.242	0.097	0.035	0.146	0.0165	0.048	0.054	0.11	0.053	0.363	0.124	0.102	0.15	0.162	0.028	0.167];
map = [9	2	5	3	7	8	2	6	9	5	9	5	8	7	6	7	6	4	9	7	9	7	9	7	8	2	9	5	7	6	5	6	5	6	5	6	1	8	10	9	6	9	6	9	6	8	4	11	5	7	5	7	4	2];

K = length(multiplier);
elec_ieee33 = zeros(size(elec,1),K);

for i = 1:K
    elec_ieee33(:,i) = multiplier(i)*elec(:,map(i));
end 

elec = elec_ieee33;

%% Power Factor, Utility Rates, Demand Charges vectors

%Building type: 1 = Residential , 2 = Commercial
%bldgtype = [2 2 2 2 2 2 2 2 2 2 1];
bldgtype = [2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	2	2	2	2	2	2];

pf = zeros(1,K);
rate = cell(1,K);
dc_exist = zeros(1,K);

for i=1:K
    if bldgtype(i) == 1 
        pf(i) = 0.95;
        rate{i} = 'R1';
        dc_exist(i) = 0; % Demand charge applicable (1 = yes, 0 = no)
    elseif bldgtype(i) == 2 
        pf(i) = 0.9;
        rate{i} = 'CI1';
        dc_exist(i) = 1;
    end 
end 