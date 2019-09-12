
%% Information of days to be selected from building load
summer_days=[22 8];
summer_weekend_start=5;
winter_days=[43 18];
winter_weekend_start=3;
  
%% AEC 31 Buildings
%load the vectors agg, bldg, comm, and time
load bldgdata\mdl_loads 

%ECM community loads (bldg with weighting factors)
%elec = [comm.all_ecm.ind comm.all_ecm.res comm.all_ecm.com]; 

%Baseload community loads (bldg with weighting factors)
elec = [comm.base.ind comm.base.res comm.base.com];  

K = size(elec,2);
T = size(elec,1);

%% Date vector
datetimev=datevec(time);

%% IF Island 
island = 0
if island ==1    
   %Shedding certain buildings
   res_shed = [10 11 12 13 14 15 16 17 18 19]; %Residential Buildings to drop
   com_shed = [20 24 26 29 30]; %Commercial bldgs to drop
   
   elec(:,res_shed) = zeros(T,length(res_shed));
   elec(:,com_shed) = zeros(T,length(com_shed));
   
   %Shedding a fraction of all loads 
   %elec = load_shedding*elec;
end 

%% Power Factor

pf = [ 0.8	0.8	0.8	0.8	0.8	0.8	0.8	0.8	0.8	0.9	0.9	0.9	0.9	0.9	0.9	0.9	0.9	0.9	0.9	0.85	0.85	0.85	0.85	0.85	0.85	0.85	0.85	0.85	0.85	0.85	0.85];%Mar.15.19

%% Utility Rates / Demand Charge 
rate={'CI2'	'CI2'	'CI2'	'CI2'	'CI2'	'CI2'	'CI2'	'CI2'	'CI2'	'R1'	'R1'	'R1'	'R1'	'R1'	'R1'	'R1'	'R1'	'R1'	'R1'	'CI1'	'CI1'	'CI1'	'CI1'	'CI1'	'CI1'	'CI1'	'CI1'	'CI1'	'CI1'	'CI1'	'CI1' };%Mar.15.19

% DC applicable (1 = yes, 0 = no)
dc_exist=[1	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	1	1	1	1	1	1	1	1	1	1	1	1];%Mar.15.19

max_elec=max(elec);   

%% Simulation time step:
t_step=round((time(2) - time(1))*(60*24));

%% Solar data
%load 'solar_m2.mat'
load 'solar_sna.mat'

%% Quick-Fix for only simulating week with worst-case RPF

duckRPF

% elec = elec(idxweekRPF,:);
% time = time(idxweekRPF);
% datetimev = datetimev(idxweekRPF,:);
% solar = solar(idxweekRPF);
% % day_multi=ones(length(elec),1);
%day_multi=ones(size(elec,1),1);

%only siulate thet DAY of the worst case RPF
elec = elec(d4,:);
time = time(d4);
datetimev = datetimev(d4,:);
solar = solar(d4);
day_multi=ones(size(elec,1),1);

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
    endpts = size(elec,1);
end

endpts

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
