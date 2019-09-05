% Inverter Constraints *with SI functions 
% Allows Pinv curtail at the AC level (<= sign)
%-> No Qelec 

%% Optimize inverter size
inv_adopt = sdpvar(1,K,'full'); %Optimize inverter size

Objective = Objective + inv_v*M*sum(inv_adopt); %Add inverter cost to objective function

%% Pinv, Qinv
Pinv = sdpvar(T,K,'full'); %kW
Qinv = sdpvar(T,K,'full'); %kVAR 
Qcap = sdpvar(T,K,'full'); %kVAR
Qind = sdpvar(T,K,'full'); %kVAR

Objective = Objective + sum(sum(Qimport)); % Adding this with the hopes of reducing Qimport

Constraints = [Constraints, 
    (Pinv <= ees_chrg - pv_elec - pv_nem - pv_wholesale - ees_dchrg - rees_dchrg - rees_dchrg_nem):'Pinv'
 %  (Qinv == -Qelec + Qind - Qcap ):'Qinv'
    (Qinv == Qind - Qcap ):'Qinv' % No more Qelec 
    ];

% Moved to opt_smart_inverter.m
%% Volt-Var curve
% VV_V1 = 0.9;
% VV_V2 = 0.97;
% VV_V3 = 1.03;
% VV_V4 = 1.1;
% VV_Q1 = 0.44;
% VV_Q2 = 0;
% VV_Q3 = 0;
% VV_Q4 = -0.44;
% 
% mcap = (VV_Q2 - VV_Q1)/(VV_V2 - VV_V1);
% mind = (VV_Q4 - VV_Q3)/(VV_V4 - VV_V3);
% 
% active = binvar(T,K,5); %There are 5 regions in the VV curve
% 
% for k = 1:K
%     tic;
%     for t = 1:T      
%         Constraints = [ Constraints, sum(active,3) == 1,
%                         (implies(active(t,k,1), [     Volts(t,T_map(k)) <= VV_V1, Qcap(t,k) == VV_Q1*inv_adopt(k) ])):'implies VV 1'; 
%                         (implies(active(t,k,2), [     Volts(t,T_map(k)) >= VV_V4, Qind(t,k) == VV_Q4*inv_adopt(k) ])):'implies VV 2';
%                         (implies(active(t,k,3), [ VV_V3 < Volts(t,T_map(k)) < VV_V4, Qind(t,k) == mind*(Volts(t,T_map(k))-0.97) ])):'implies VV 3';
%                         (implies(active(t,k,4), [ VV_V2 <= Volts(t,T_map(k)) <= VV_V3, Qind(t,k) == 0, Qcap == 0 ])):'implies VV 4';
%                         (implies(active(t,k,5), [   VV_V1 < Volts(t,T_map(k)) < VV_V2, Qcap(t,k) == mcap*(Volts(t,T_map(k))- 1.03)])):'implies VV 5';
%                       ];
%     end
%     tinvk = toc    
% end
% 
% %% Volt-Watt 
% VW_V1 = 1;
% VW_V2 = 0.93;
% VW_V3 = 1.06;
% VV_P1 = 1;
% VV_P2 = 1;
% VV_P3 = 0;
% 
% mvw =  (VV_P3 - VV_P2) /  (VW_V3 - VW_V2 );
% 
% active = binvar(T,K,2); %We have 2 other regions in the VW curve
% for k = 1:K
%     %First region 
%     Constraints = [Constraints, (Pinv(:,k) <= inv_adopt(k)):'VW region 1'];   
%     tic;
%     for t = 1:T      
%         Constraints = [ Constraints, sum(active,3) == 1,
%                         (implies(active(t,k,1), [ VV_V2 < Volts(t,T_map(k)) < VV_V3, Pinv(t,k) <= mvw*(Volts(t,T_map(k))-1.06) ])):'implies VW 2';
% 	                    (implies(active(t,k,2), [    Volts(t,T_map(k)) > VV_V3, Pinv(t,k) == 0 ])):'implies VW 2';
%                       ];
%     end
%     tinvk = toc    
% end 


%% Inverter Polygon Constraints
L = 22; % number of line segments of the polygon
i = 0:L-1;
theta = pi/L + i.*(2*pi)./L; %rad
C = [cos(theta)' sin(theta)'];
s = inv_adopt*cos(theta(1));

if ic % If Inv. constraints ON
    for k=1:K %for each bldg
    Constraints = [Constraints, (C*[Pinv(:,k)';Qinv(:,k)'] <= s(k)):'Inv. Polygon Constraint'];
    %Constraints = [Constraints, (inv_adopt(k)>= Qelec(:,k)+Qcap(:,k)):'Inv. Q OUT limit']; 
    Constraints = [Constraints, (inv_adopt(k)>= Qcap(:,k)):'Inv. Q OUT limit']; % No more Qelec
    Constraints = [Constraints, (inv_adopt(k)>= Qind(:,k)):'Inv. Q IN limit'];
    Constraints = [Constraints, (inv_adopt(k)>= ees_chrg(:,k)):'Inv. P IN Limit'];
    Constraints = [Constraints, (inv_adopt(k)>= pv_elec(:,k) + pv_nem(:,k) + pv_wholesale(:,k) + rees_dchrg_nem(:,k) + rees_dchrg(:,k) + ees_dchrg(:,k)):'Inverter P OUT Limit'];
    end 
end 