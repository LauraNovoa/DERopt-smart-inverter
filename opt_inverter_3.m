%Inverter Constraints 
%The inverter can be:
%(1) Standard: Does not curtail PV on DC/AC side. No Qelec (meet building Q load) or Qind or Qcap (to regulate voltage)
%(2) Optimal: Curtails PV on AC side. Qelec, Qind, and Qcap optimal output (without droop-control)
%(3) Smart-Inverter: Curtails PV on AC side. Qind, and Qcap droop-control output, Qelec = 0 ( does not meet building Q load)

inv_adopt = sdpvar(1,K,'full'); %Inverter size

Objective = Objective + inv_v*sum(inv_adopt); %Add inverter cost to objective function

%% Pinv, Qinv, and Polygon Constraints 
Pinv = sdpvar(T,K,'full'); %kW
Pinv_in = sdpvar(T,K,'full'); %kW
Pinv_out = sdpvar(T,K,'full'); %kW
Pinv_curtail = sdpvar(T,K,'full'); %kW
Qinv = sdpvar(T,K,'full'); %kVAR 
Qanc = sdpvar(T,K,'full'); %kVAR
Qinv_in = sdpvar(T,K,'full'); %kVAR 
Qinv_out = sdpvar(T,K,'full'); %kVAR 
Qcap = sdpvar(T,K,'full'); %kVAR
Qind = sdpvar(T,K,'full'); %kVAR

%Objective = Objective + sum(sum(Qind)) + sum(sum(Qcap)); % Adding this to reduce Qind and Qcap
%Objective = Objective + sum(sum(Qimport)); % Adding this to reduce Qimport and meeting Qbldg qith Qelec

    Constraints = [Constraints 
        (Pinv == Pinv_in - Pinv_out):'Pinv'
        (Pinv_in == ees_chrg):'Pinv_in'
        (Pinv_out == pv_elec + pv_nem + pv_wholesale + ees_dchrg + rees_dchrg + rees_dchrg_nem):'Pinv_out'
        (Qinv == -Qelec + Qanc ):'Qinv'
        (Qanc == Qind - Qcap):'Qanc = Qind - Qcap'
        (Qinv == Qinv_in - Qinv_out ):'Qinv'
        (Qinv_in == Qind  ):'Qinv_in'
        (Qinv_out == Qelec + Qcap ):'Qinv_out'
        (Pinv_in >= 0):'Pinv_in >=0'
        (Pinv_out >= 0):'Pinv_out >=0'
        (Qcap >=0):'Qcap >=0'
        (Qind >=0):'Qind >=0'
        (Qinv_in >= 0):'Qinv_in >=0'
        (Qinv_out >= 0):'Qinv_out >=0'
     ]; 

if invertermode == 1 %Standard inverter 
    % No Pinv curtail at the AC side (Pinv_out == (...)
    % No reactive power compensation (Qind, Qcap) nor reactive power to the building(Qelec) , so Qinv =0
    Constraints = [Constraints
        (Qelec == 0):'Qelec = 0'
        (Qanc == 0):'Qanc = 0'   
    ];

        bldg = []
        
elseif invertermode == 2 %Smart inverter with PQ VVO
        
        bldg = []
        
elseif invertermode ==3 %Smart-Inverter with droop-control
 
    % No Qelec
    Constraints = [Constraints
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
        (inv_adopt(k)>= Qinv_in(:,k)):'Inv. Q IN limit'
        (inv_adopt(k)>= Qinv_out(:,k)):'Inv. Q OUT limit'
        ]; 
    end 
end 