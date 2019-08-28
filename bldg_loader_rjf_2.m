
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
% cooling=zeros(size(elec));
% heating=zeros(size(elec));

    %Converts 15min to hourly 
%     elec=zeros(length(time),size(elec_facility,2));
%     for i=1:size(elec,1)
%         elec(i,:) = sum(elec_facility(1+4*(i-1):4*i,:),1);
%     end

%% Simulation time step:
t_step=round((time(2) - time(1))*(60*24));

%% Solar data
%load 'solar_m2.mat'
load 'solar_sna.mat'

%%%Convert Solar to hourly if 60 minte increments
if t_step == 60 && length(solar) ~= length(elec)
    solar_o=solar;
    solar=[];
    ii=1;
    avg=0;
    count=1;
    for i=1:length(solar_o)
        avg=avg+solar_o(i);
        
        if rem(count,4) == 0
            solar(ii,1) = avg/4;
            ii=ii+1;
            count=1;
            avg=0;
        else
            count=count+1;
        end
    end

    %%%Add length to solar to be chopped later
    for i= 1:ceil(nthroot(length(time)/length(solar),2))
        solar = [solar solar];
    end
    
    %%%If t_step is 15 minuites
elseif t_step == 15
    %%% Convert average solar power per 15 minutes to energy available per 15 minutes
    %solar=solar./4;
    
end

%% Quick-Fix for only simulating week with worst-case RPF
duckRPF
elec = elec(idxweekRPF,:);
time = time(idxweekRPF);
datetimev = datetimev(idxweekRPF,:);
solar = solar(idxweekRPF);
day_multi=ones(length(elec),1);

 %% Converting 8760 to 864 
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
% 
% %% Filtering Data
% if filtering == 1
%     %%% Moving Average Window
%     filter_data_elec = zeros(size(elec));
%     filter_data_cooling = zeros(size(cooling));
%     filter_data_heating = zeros(size(heating));
%     %%%At each point, take the average of the surrounding points
%     for i=window+1:size(elec,1)-window
%         for j=1:size(elec,2)
%             filter_data_elec(i,j)=mean(elec(i-window:i+window,j));
%         end
%         filter_data_cooling(i,1)=mean(cooling(i-window:i+window,1));
%         filter_data_heating(i,1)=mean(heating(i-window:i+window,1));
%     end
%     
%     filter_data_elec(1:4,:)=elec(1:4,:);
%     filter_data_elec(2015:2018,:)=elec(2015:2018,:);
%     
%     filter_data_cooling(1:4,:)=cooling(1:4,:);
%     filter_data_cooling(2015:2018,:)=cooling(2015:2018,:);
%     
%     filter_data_heating(1:4,:)=heating(1:4,:);
%     filter_data_heating(2015:2018,:)=heating(2015:2018,:);
%     
%     for j=1:size(elec,2)
%         for i=2:length(filter_data_elec)-1
%             if filter_data_elec(i,j)<30
%                 filter_data_elec(i,j)=filter_data_elec(i-1,j);
%             end
%         end
%     end
%     
%     figure
%     a1=subplot(1,3,1);
%     hold on
%     plot(elec(:,2),'Color',[0 0 1])
%     plot(filter_data_elec(:,2),'Color',[.8 0 0])
%     hold off
%     
%     a2=subplot(1,3,2);
%     hold on
%     plot(cooling,'Color',[0 0 1])
%     plot(filter_data_cooling,'Color',[.8 0 0])
%     hold off
%     
%     a3=subplot(1,3,3);
%     hold on
%     plot(heating,'Color',[0 0 1])
%     plot(filter_data_heating,'Color',[.8 0 0])
%     hold off
%     
%     A=[a1 a2 a3];
%     linkaxes(A,'x');
%     
%     elec=filter_data_elec;
%     cooling=filter_data_cooling;
%     heating=filter_data_heating;
% elseif filtering == 2
%     %%%Only filtering really low data
%     figure
%     hold on
%     plot(elec(:,2))
%     for i=2:length(elec)-1
%         if elec(i,2)<mean(elec(:,2))*min_percent
%             elec(i,2)=(elec(i-1,2)+elec(i+1,2))/2;
%         end
%     end
%     plot(elec(:,2),'r')
%     hold off
% end
% 
% if bldgnum==5
%     for i=10:length(elec)-10
%         if elec(i,2)<65
%             i;
%             elec(i,2)=elec(i-1,2);
%         end
%     end
% end
% 
% if bldgnum ==1
%     for i=3:length(elec)-3
%         for j=1:size(elec,2)
%             if elec(i,j)<50
%                 elec(i,j)=(elec(i-2,j)+elec(i-1,j)+elec(i+1,j)+elec(i+2,j))/2;
%             end
%         end
%     end
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

%% Building cooling Max Load
% cooling_max=max(cooling);
