close all

%Plot, for a given building:
% (1) inverter
% (2) transformer 
% (3) building  

%% Color Palletes
load('palletes_ldn');
pallete = bright;

    n = size(mpc.bus,1);
    m = size(mpc.branch,1);
    if m <=54
    s = 1; %spacing between xticks
    elseif m >= 105
        s = 4; 
    else m > 54
        s = 3;
    end 

    
 k=1; %Choose building #
 s=1; %spacing for x axis
 tlim1 = 0;
 tlim2 = 24; % Limit for x-axis (for all plots)

 legon = 0;
 leglocation = 'best';
 alpha = 1; %08 for ransparent legend 
 
%%  Inverter dynamics

    Position = [467   -53   812   515];
    fig = figure('Position', Position ,'PaperPositionMode','auto');
    fig.Color = 'w';
    ax = axes('Parent',fig,'XTick',1:s:t); % set xticklabel to '' to remove ticks
    box(ax,'on'); hold(ax,'on');
    ax.Color = [234 234 242]./255; % set background gray
    grid on; ax.GridColor = [255,255,255]./255; 
    ax.GridAlpha = 0.9; %set grid white with transparency
    ax.TickLength = [0 0];
    
    h1 = plot(1:t,Pinv(:,k),'Color',[pallete(2,:) 1],'LineStyle','-','LineWidth',1.5);    
    h2 = plot(1:t,Qinv(:,k),'Color',[pallete(3,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','d');
    h3 = plot(1:t,Sinv(:,k),'Color',[pallete(10,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','*');
    h4 = plot(1:t,Qelec(:,k),'Color',[pallete(4,:) 1],'LineStyle','--','LineWidth',1.5,'Marker','none');
    %h5 = plot(1:t,Qind(:,k),'Color',[pallete(5,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','none');
    %h6 = plot(1:t,-Qcap(:,k),'Color',[pallete(1,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','none');
    h5 = bar(1:t,Qind(:,k),'FaceColor',[pallete(5,:)]);
    h6 = bar(1:t,Qcap(:,k),'FaceColor',[pallete(1,:)]);
    h7 = plot(1:t,Qimport(:,k),'Color',[pallete(9,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','none');
    h8 = plot(1:t,-(pv_wholesale(:,k) + pv_elec(:,k) + ees_chrg_pv(:,k) + pv_nem(:,k) + rees_chrg(:,k)),'Color',[pallete(6,:) 1],'LineStyle','-','LineWidth',1.0);
    h9 = plot(1:t,-(ees_dchrg(:,k) + rees_dchrg(:,k) + rees_dchrg_nem(:,k)),'Color',[pallete(7,:) 1],'LineStyle','-','LineWidth',1.0);
    l =  line(1:t,ones(1,t)*inv_adopt(k),'Color',[pallete(8,:) 1],'LineStyle',':','LineWidth',2.0);hold on;
 
    %[leg, objects ] = legend('Pinv (+)import (-)export','Qinv = -Qelec + Qanc (+) import/ind','Sinv = sqrt(Pinv^2 + Qinv^2)','Qelec','Qanc inv (+) import/ind','Qimport bldg','PV (DC) generation','EES+REES dch (DC)','Inverter kVA','Location',leglocation);
    if legon
        [leg, objects ] = legend('Pinv (+)import (-)export','Qinv = -Qelec + Qind - Qcap (+) import/ind','Sinv = sqrt(Pinv^2 + Qinv^2)','Qelec','Qind (+)','Qcap (-)','Qimport bldg','PV (DC) generation','EES+REES dch (DC)','Inverter kVA','Location',leglocation);
        leg.BoxFace.ColorType = 'truecoloralpha';
        leg.BoxFace.ColorData = uint8([234 234 242 242*alpha]');
    end
    
    ax.FontSize = 12;
    %ax.XTickLabelRotation = 90;
    
    %Secondary y axis
    %'Position', ax.Position,
    ax2 = axes('YAxisLocation','Right','Parent',fig,'XTick',1:s:t,'XTickLabel','','Color','none');
    h10 = line(1:t,BusVolAC(T_map(k),:),'Parent',ax2,'Color',[pallete(8,:) 1],'LineStyle','-','LineWidth',1.2);hold on;
    
    [leg2, objects2 ] = legend('Volts','Location','northeast');
    leg2.BoxFace.ColorType = 'truecoloralpha';
    leg2.BoxFace.ColorData = uint8([234 234 242 242*0.8]');

    title(sprintf('Inverter Dynamics | %.0f kVA | XFMR: %.0f kVA | Bldg:%.0f',inv_adopt(k),T_rated(T_map(k)),k))
    ax.YLabel.String='kW/kVar';
    ax2.YLabel.String ='Volts';
    ax.XLabel.String = 'Hour';
    ax.XLim =[tlim1 tlim2];
    ax2.XLim = [tlim1 tlim2];
    %ax2.YLim = [0 1.3];
    tix=get(ax,'ytick')';
    set(ax,'yticklabel',num2str(tix,'%.0f'));
    %tix2=get(ax,'xtick')';
    %set(ax,'xticklabel',num2str(tix2,'%.0f'));
    ax.YMinorTick = 'on';
   

%%  Transformer dynamics
%     fig = figure('Position', Position ,'PaperPositionMode','auto');
%     fig.Color = 'w';
%     ax = axes('Parent',fig,'XTick',1:s:t); % set xticklabel to '' to remove ticks
%     box(ax,'on'); hold(ax,'on');
%     ax.Color = [234 234 242]./255; % set background gray
%     grid on; ax.GridColor = [255,255,255]./255; 
%     ax.GridAlpha = 0.9; %set grid white with transparency
%     ax.TickLength = [0 0];
%     
%     h1 = plot(1:t,Pinj(:,T_map(k)),'Color',[pallete(2,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','none');    
%     h2 = plot(1:t,Qinj(:,T_map(k)),'Color',[pallete(3,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','d');
%     h3 = plot(1:t,Sinj(:,T_map(k)),'Color',[pallete(10,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','*');
%     h4 = plot(1:t,Qimport(:,k),'Color',[pallete(9,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','none');
%     %h5 = plot(1:t,Qanc(:,k),'Color',[pallete(5,:) 1],'LineStyle',':','LineWidth',1.5,'Marker','+');
%     h5 = plot(1:t,Qind(:,k),'Color',[pallete(5,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','none');
%     h6 = plot(1:t,-Qcap(:,k),'Color',[pallete(1,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','none');
%     l =  line(1:t,ones(1,t)*T_rated(T_map(k)),'Color',[pallete(8,:) 1],'LineStyle',':','LineWidth',2.0);
%  
%     %[leg, objects ] = legend('Pinj (+) import','Qinj = Qimport + Qanc (+) import/ind','Sinj (+) import/ind','Qimport (+)','Qanc (+)import/ind','Transformer kVA','Location',leglocation);
%     if legon
%         [leg, objects ] = legend('Pinj (+) import','Qinj = Qimport + Qanc (+) import/ind','Sinj (+) import/ind','Qimport (+)','Qind (+)','Qcap (-)','Transformer kVA','Location',leglocation);
%         leg.BoxFace.ColorType = 'truecoloralpha';
%         leg.BoxFace.ColorData = uint8([234 234 242 242*alpha]');
%     end 
%     
%     ax.FontSize = 12;
%     %ax.XTickLabelRotation = 90;
%     
%     %Secondary y axis
%     %'Position', ax.Position,
%     ax2 = axes('YAxisLocation','Right','Parent',fig,'XTick',1:s:t,'XTickLabel','','Color','none');
%     h8 = line(1:t,BusVolAC(T_map(k),:),'Parent',ax2,'Color',[pallete(8,:) 1],'LineStyle','-','LineWidth',1.2);hold on;
%     
%     if legon
%         [leg2, objects2 ] = legend('Volts','Location','northeast');
%         leg2.BoxFace.ColorType = 'truecoloralpha';
%         leg2.BoxFace.ColorData = uint8([234 234 242 242*0.8]');
%     end 
%     
%     title(sprintf('Transformer Dynamics | %.0f kVA | Bldg: %.0f',T_rated(T_map(k)),k))
%     xlabel('Time step (hour)');
%     ax.YLabel.String='kW/kVar';
%     ax2.YLabel.String ='Volts';
%     ax.XLim =[tlim1 tlim2];
%     ax2.XLim = [tlim1 tlim2];
%     tix=get(ax,'ytick')';
%     set(ax,'yticklabel',num2str(tix,'%.0f'));
%     tix2=get(ax,'xtick')';
%     set(ax,'xticklabel',num2str(tix2,'%.0f'));
%     ax.YMinorTick = 'on';
    
    %%  Building Q dynamics
%     fig = figure('Position', Position ,'PaperPositionMode','auto');
%     fig.Color = 'w';
%     ax = axes('Parent',fig,'XTick',1:s:t); % set xticklabel to '' to remove ticks
%     box(ax,'on'); hold(ax,'on');
%     ax.Color = [234 234 242]./255; % set background gray
%     grid on; ax.GridColor = [255,255,255]./255; 
%     ax.GridAlpha = 0.9; %set grid white with transparency
%     ax.TickLength = [0 0];
%     
%     Qbldg = (elec(:,k)).*tan(acos(pf(k)));
%     h1 = plot(1:t,Qbldg,'Color',[pallete(1,:) 1],'LineStyle','-','LineWidth',1.5,'Marker','d');    
%     h2 = plot(1:t,Qimport(:,k),'Color',[pallete(9,:) 1],'LineStyle','--','LineWidth',1.5,'Marker','none');
%     h3 = plot(1:t,Qelec(:,k),'Color',[pallete(4,:) 1],'LineStyle','--','LineWidth',1.5,'Marker','none');
% 
%     if legon
%         [leg, objects ] = legend('Qbldg (+)','Qimport (+)','Qelec','Location','northwest');
%         leg.BoxFace.ColorType = 'truecoloralpha';
%         leg.BoxFace.ColorData = uint8([234 234 242 242*alpha]');
%     end 
%     
%     ax.FontSize = 12;
%     %ax.XTickLabelRotation = 90;
%     
%     %Secondary y axis
%     %'Position', ax.Position,
%     ax2 = axes('YAxisLocation','Right','Parent',fig,'XTick',1:s:t,'XTickLabel','','Color','none');
%     h8 = line(1:t,BusVolAC(T_map(k),:),'Parent',ax2,'Color',[pallete(8,:) 1],'LineStyle','-','LineWidth',2.0);hold on;
%     
%     if legon
%         [leg2, objects2 ] = legend('Volts','Location','northeast');
%         leg2.BoxFace.ColorType = 'truecoloralpha';
%         leg2.BoxFace.ColorData = uint8([234 234 242 242*alpha]');
%     end 
%     
%     title(sprintf('Building %.0f Dynamics',k))
%     xlabel('Time step (hour)');
%     ax.YLabel.String='kW/kVar';
%     ax2.YLabel.String ='Volts';
%     ax.XLim =[tlim1 tlim2];
%     ax2.XLim = [tlim1 tlim2];
%     tix=get(ax,'ytick')';
%     set(ax,'yticklabel',num2str(tix,'%.0f'));
%     tix2=get(ax,'xtick')';
%     set(ax,'xticklabel',num2str(tix2,'%.0f'));
%     ax.YMinorTick = 'on';
    
    %% Power Factor dynamics 
    
%     fig = figure('Position', Position ,'PaperPositionMode','auto'); fig.Color = 'w';
%     ax = axes('Parent',fig,'XTick',1:s:t); % set xticklabel to '' to remove ticks
%     box(ax,'on'); hold(ax,'on');
%     ax.Color = [234 234 242]./255; % set background gray
%     grid on; ax.GridColor = [255,255,255]./255; ax.GridAlpha = 0.9; %set grid white with transparency
%     ax.TickLength = [0 0];
%     
%     PFinv = zeros(t,1); 
%     PFinj = zeros(t,1); 
%     PFbldg = zeros(t,1);
%     
%     %PF: IEEE sign convention:
%     % (-) inductive   Q > 0
%     % (+) capacitive  Q < 0
%     % Q = 0 , PF = 1 (pure resistive load )
%     % P = 0 , PF = 0 (pure reactive load)
%     for i=1:t 
%         %PFinv
%         if Qinv(i,k) == 0
%             PFinv(i) = 1;
%         elseif Pinv(i) == 0
%             PFinv(i) = 0;
%         elseif Qinv(i) >0
%             PFinv(i) = -1.*cos(atan(Qinv(i,k)./Pinv(i,k)));
%         else
%             PFinv(i) = cos(atan(Qinv(i,k)./Pinv(i,k)));
%         end
%         
%         %PFinj
%         if Qinj(i,T_map(k)) == 0
%             PFinj(i) = 1;
%         elseif Pinj(i,T_map(k)) == 0
%             PFinj(i) = 0;
%         elseif Qinj(i,T_map(k)) >0
%             PFinj(i) = -1.*cos(atan(Qinj(i,T_map(k))./Pinj(i,T_map(k))));
%         else
%             PFinj(i) = cos(atan(Qinj(i,T_map(k))./Pinj(i,T_map(k))));     
%         end
%    
%     end 
%                        
%     h1 = plot(1:t,PFinv,'Color',[pallete(11,:) 1],'LineStyle','none','LineWidth',0.5,'Marker','o','MarkerSize',5,'MarkerFaceColor',pallete(1,:));    
%     h2 = plot(1:t,PFinj,'Color',[pallete(11,:) 1],'LineStyle','none','LineWidth',0.5,'Marker','o','MarkerSize',5,'MarkerFaceColor',pallete(9,:));
%     h3 = plot(1:t,pf(k)*ones(t),'Color',[pallete(11,:) 1],'LineStyle','none','LineWidth',0.5,'Marker','o','MarkerSize',5,'MarkerFaceColor',pallete(7,:));
%     
%     if legon
%     [leg, objects ] = legend('PF inverter (+) leading/cap (-) lagging/ind','PF XFMR',sprintf('PF Bldg: %.1f', pf(k)),'Location',leglocation);
%     leg.BoxFace.ColorType = 'truecoloralpha';
%     leg.BoxFace.ColorData = uint8([234 234 242 242*alpha]');  
%     end 
%     
%     title(sprintf('Power factor of Inverter and XFMR | Bldg %.0f ',k))
%     xlabel('Time step (hour)');
%     ax.YLabel.String='Power Factor';
%     ax.FontSize = 12;
%     ylim([-1.1 1.1])
%     ax.XLim =[tlim1 tlim2];
%     %tix=get(ax,'ytick')';
%     %set(ax,'yticklabel',num2str(tix,'%.0f'));
%     ax.YMinorTick = 'on';
%     