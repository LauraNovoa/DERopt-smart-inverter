%Reverse Power Flow
Totalelec = sum(elec,2);
Solar = 4000*solar;

duck  = Totalelec - Solar;

%Soted duck courve -> First entry is the worst RPF 
[sortduck,idx]= sort(duck);

%Ten worst RPF
tenworstRPF = datetimev(idx(1:10),:);

%Get month, day, and hour from time
month = datetimev(:,2); day = datetimev(:,3); hour = datetimev(:,4);

%Find day that the WORST RPF happens
datemaxRPF = datetimev(idx(1),:)
datemaxRPF(1,4) = 0;

%find indices for this day
d4 = find(datetimev(:,2) == datemaxRPF(:,2) & datetimev(:,3) == datemaxRPF(:,3));
%find indices for the day before
d1 = find(datetimev(:,2) == datemaxRPF(:,2) & datetimev(:,3) == datemaxRPF(:,3)-1);
%and two days before
d2 = find(datetimev(:,2) == datemaxRPF(:,2) & datetimev(:,3) == datemaxRPF(:,3)-2);
%and three days before
d3 = find(datetimev(:,2) == datemaxRPF(:,2) & datetimev(:,3) == datemaxRPF(:,3)-3);
%and one day after
d5 = find(datetimev(:,2) == datemaxRPF(:,2) & datetimev(:,3) == datemaxRPF(:,3)+1);
%and two days after
d6 = find(datetimev(:,2) == datemaxRPF(:,2) & datetimev(:,3) == datemaxRPF(:,3)+2);
%and three days after
d7 = find(datetimev(:,2) == datemaxRPF(:,2) & datetimev(:,3) == datemaxRPF(:,3)+3);

%Find indices for the week that worst RPF happens:
idxweekRPF = [d1;d2;d3;d4;d5;d6;d7];
elecweek = elec(idxweekRPF,:);

% figure
% plot(AECelec(idxweekRPF))
% hold on 
% plot(duck(idxweekRPF))
% figure
% plot(sortduck,'LineStyle','none','Marker','.')

%hold on 
%plot(-Solar(weekRPF))
% figure
% plot(duck)
% figure
% plot(3000*solar)
% hold on
% plot(sum(elec,2))