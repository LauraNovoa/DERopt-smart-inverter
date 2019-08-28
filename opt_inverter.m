%Inverter Constraints 

inv_adopt = sdpvar(1,K,'full'); %Optimize inverter size

Objective = Objective + inv_v*M*sum(inv_adopt); %Add inverter cost to objective function

%% Pinv, Qinv, and Polygon Constraints 
Pinv = sdpvar(T,K,'full'); %kW
Qinv = sdpvar(T,K,'full'); %kVAR 
%Qanc = sdpvar(T,K,'full'); %kVAR
Qcap = sdpvar(T,K,'full'); %kVAR
Qind = sdpvar(T,K,'full'); %kVAR

%Objective = Objective + sum(sum(Qind)) + sum(sum(Qcap)); % Adding this with the hopes of reducing Qind anc Qcap

Objective = Objective + sum(sum(Qimport)); % Adding this with the hopes of reducing Qimport and meeting Qbldg qith Qelec

Constraints = [Constraints, 
    (Pinv == ees_chrg - pv_elec - pv_nem - pv_wholesale - ees_dchrg - rees_dchrg - rees_dchrg_nem):'Pinv'
    %(Qinv == -Qelec + Qanc ):'Qinv' 
    (Qinv == -Qelec + Qind - Qcap ):'Qinv'
    ];

%Inverter Polygon Constraints
L = 22; % number of line segments of the polygon
i = 0:L-1;
theta = pi/L + i.*(2*pi)./L; %rad
C = [cos(theta)' sin(theta)'];
s = inv_adopt*cos(theta(1));

if ic % If Inv. constraints ON
    for k=1:K %for each bldg
    Constraints = [Constraints, (C*[Pinv(:,k)';Qinv(:,k)'] <= s(k)):'Inv. Polygon Constraint'];
    %Constraints = [Constraints, (inv_adopt(k)>=Qelec(:,k)):'Inv. Q OUT limit'];
    Constraints = [Constraints, (inv_adopt(k)>= Qelec(:,k)+Qcap(:,k)):'Inv. Q OUT limit'];
    Constraints = [Constraints, (inv_adopt(k)>= Qind(:,k)):'Inv. Q IN limit'];
    Constraints = [Constraints, (inv_adopt(k)>= ees_chrg(:,k)):'Inv. P IN Limit'];
    Constraints = [Constraints, (inv_adopt(k)>= pv_elec(:,k) + pv_nem(:,k) + pv_wholesale(:,k) + rees_dchrg_nem(:,k) + rees_dchrg(:,k) + ees_dchrg(:,k)):'Inverter P OUT Limit'];
    end 
end 