load('U:\Runs\DERopt+Inverter\ACDC.mat');
ACDC = ACDC(1:end-1,:);

PV = ACDC(:,1)
Baseline = ACDC(:,2);
PQ = ACDC(:,3);
VV = ACDC(:,4);

Position = [ 541   303   607   427];
fig = figure('Position', Position ,'PaperPositionMode','auto');
fig.Color = 'w';
ax = axes('Parent',fig,'XTick',1:1:K); % set xticklabel to '' to remove ticks
box(ax,'on'); hold(ax,'on');
ax.Color = [234 234 242]./255; % set background gray
grid on; ax.GridColor = [255,255,255]./255; 
ax.GridAlpha = 0.9; %set grid white with transparency
ax.TickLength = [0 0];

s1 = plot(1:31,PV,'Color',pallete(2,:),'LineStyle','none','Marker','o','LineWidth',2.0)
s2 = plot(1:31,Baseline,'Color',pallete(3,:),'LineStyle','none','Marker','+','LineWidth',2.0)
s3 = plot(1:31,PQ,'Color',pallete(4,:),'LineStyle','none','Marker','d','LineWidth',2.0)
s4 = plot(1:31,VV,'Color',pallete(5,:),'LineStyle','none','Marker','s','LineWidth',2.0)


[leg, objects ]  = legend([s1(1) s2(1) s3(1) s4(1)], 'Solar PV','Baseline','PQ control','Volt-Var','Location','best');
leg.BoxFace.ColorType = 'truecoloralpha';
leg.BoxFace.ColorData = uint8([234 234 242 242*alpha]');
ax.XLim = [0 K];
ax.YLim = [0 650];

%Secondary y axis
ax2 = axes('YAxisLocation','Right','Parent',fig,'XTick',1:1:K,'XTickLabel','','Color','none');
    for k =1:K
        p1 = line(k,max(Volts(T_map(k),:)),'Parent',ax2,'Color','k','LineStyle','none','LineWidth',1.2,'Marker','o');hold on;
        p2 = line(k,min(Volts(T_map(k),:)),'Parent',ax2,'Color','k','LineStyle','none','LineWidth',1.2,'Marker','o');hold on;
    end 
     
    %h10 = line(1:k,BusVolAC(T_map(k),:),'Parent',ax2,'Color',[pallete(11,:) 1],'LineStyle','-','LineWidth',1.2);hold on;
    [leg2, objects2 ] = legend('Voltage range','Location','northeast');
    leg2.BoxFace.ColorType = 'truecoloralpha';
    leg2.BoxFace.ColorData = uint8([234 234 242 242*0.8]');

ax2.XLim = [0 K];
