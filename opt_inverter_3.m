%Inverter Constraints 
%The inverter can be:
%(1) Standard: Does not curtail PV on DC/AC side. No Qelec (meet building Q load) or Qind or Qcap (to regulate voltage)
%(2) Optimal: Curtails PV on AC side. Qelec, Qind, and Qcap optimal output (without droop-control)
%(3) Smart-Inverter: Curtails PV on AC side. Qind, and Qcap droop-control output, Qelec = 0 ( does not meet building Q load)

inv_adopt = sdpvar(1,K,'full'); %Inverter size

%Objective = Objective + inv_v*M*sum(inv_adopt); %Add inverter cost to objective function

%% Pinv, Qinv, and Polygon Constraints 
Pinv = sdpvar(T,K,'full'); %kW
Pinv_in = sdpvar(T,K,'full'); %kW
Pinv_out = sdpvar(T,K,'full'); %kW
Qinv = sdpvar(T,K,'full'); %kVAR 
Qanc = sdpvar(T,K,'full'); %kVAR
%Qinv_in = sdpvar(T,K,'full'); %kVAR 
%Qinv_out = sdpvar(T,K,'full'); %kVAR 
%Qcap = sdpvar(T,K,'full'); %kVAR
%Qind = sdpvar(T,K,'full'); %kVAR

%Objective = Objective + sum(sum(Qind)) + sum(sum(Qcap)); % Adding this with the hopes of reducing Qind anc Qcap

%Objective = Objective + sum(sum(Qimport)); % Adding this with the hopes of reducing Qimport and meeting Qbldg qith Qelec

    Constraints = [Constraints 
        (Pinv == Pinv_in - Pinv_out):'Pinv'
        (Pinv_in == ees_chrg):'Pinv_in'
        (Pinv_out == pv_elec + pv_nem + pv_wholesale + ees_dchrg + rees_dchrg + rees_dchrg_nem):'Pinv_out'
         Pinv_in >= 0;
         Pinv_out >= 0; 
        (Qinv == -Qelec + Qanc ):'Qinv'
        %(Qinv == Qinv_in - Qinv_out ):'Qinv'
        %(Qinv_in == Qind  ):'Qinv_in'
        %(Qinv_out == Qelec + Qcap ):'Qinv_out'
         %Qinv_in >= 0;
         %Qinv_out >= 0;
     ]; 

if invertermode == 1 %Standard inverter 
    % No Pinv curtail at the AC side (Pinv == (...)
    % No reactive power compensation (Qind, Qcap) nor reactive power to the building(Qelec) , so Qinv =0
    Constraints = [Constraints
        %(Pinv == ees_chrg - pv_elec - pv_nem - pv_wholesale - ees_dchrg - rees_dchrg - rees_dchrg_nem):'Pinv (Standard Inverter)'
        %(Pinv_out == pv_elec + pv_nem + pv_wholesale + ees_dchrg + rees_dchrg + rees_dchrg_nem):'Pinv_out (Standard Inverter)'
        (Qelec == 0):'Qelec = 0'
        (Qanc == 0):'Qanc = 0'
        %(Qind == 0):'Qind = 0'
        %(Qcap == 0):'Qcap = 0'
    ];

    
elseif invertermode ==3 %Smart-Inverter with droop-control
    
    % Allows Pinv curtail at the AC level (Pinv_out <= (...))
    % No Qelec
    Constraints = [Constraints
        %(Pinv <= ees_chrg - pv_elec - pv_nem - pv_wholesale - ees_dchrg - rees_dchrg - rees_dchrg_nem):'Pinv (Smart Inverter)'
        %(Pinv_out <= pv_elec + pv_nem + pv_wholesale + ees_dchrg + rees_dchrg + rees_dchrg_nem):'Pinv_out (Smart Inverter)'       
        (Qelec == 0):'Qelec = 0'
        ];

end

%Inverter Polygon Constraints
L = 22; % number of line segments of the polygon
i = 0:L-1;
theta = pi/L + i.*(2*pi)./L; %rad
C = [cos(theta)' sin(theta)'];
s = inv_adopt*cos(theta(1));

if ic % If Inv. constraints ON
    for k=1:K %for each bldg
    Constraints = [Constraints
        (C*[Pinv(:,k)';Qinv(:,k)'] <= s(k)):'Inv. Polygon Constraint'
        (inv_adopt(k)>= Pinv_in(:,k)):'Inv. P IN Limit'
        (inv_adopt(k)>= Pinv_out(:,k)):'Inv. P OUT Limit'
        %(inv_adopt(k)>= Qinv_in(:,k)):'Inv. Q IN limit'
        %(inv_adopt(k)>= Qinv_out(:,k)):'Inv. Q OUT limit'
        ];
        
    %Constraints = [Constraints, (inv_adopt(k)>= Qelec(:,k)+Qcap(:,k)):'Inv. Q OUT limit'];
    %Constraints = [Constraints, (inv_adopt(k)>= Qind(:,k)):'Inv. Q IN limit'];
    %Constraints = [Constraints, (inv_adopt(k)>= ees_chrg(:,k)):'Inv. P IN Limit'];
    %Constraints = [Constraints, (inv_adopt(k)>= pv_elec(:,k) + pv_nem(:,k) + pv_wholesale(:,k) + rees_dchrg_nem(:,k) + rees_dchrg(:,k) + ees_dchrg(:,k)):'Inverter P OUT Limit'];
    
    end 
end 