%% YALMIP Conversions

Objective = value(Objective);

import=value(import);

%Demand Charges
if sum(dc_exist) > 0
    onpeak_dc=value(onpeak_dc);
    midpeak_dc=value(midpeak_dc);
    nontou_dc=value(nontou_dc);
end

%PV
if isempty(pv_v) == 0
    pv_adopt=value(pv_adopt);
    pv_elec=value(pv_elec);
    pv_nem = value(pv_nem);
    pv_wholesale = value(pv_wholesale);
end

%EES
if isempty(ees_v) == 0
    ees_adopt = value(ees_adopt);
    ees_soc = value(ees_soc);
    ees_dchrg = value(ees_dchrg);
    ees_chrg = value(ees_chrg);
    ees_chrg_pv = value(ees_chrg_pv);
else
    ees_adopt=zeros(1,K);
end

%REES
if isempty(ees_v) == 0 & rees_exist == 1
    rees_adopt = value(rees_adopt);
    rees_soc = value(rees_soc);
    rees_dchrg = value(rees_dchrg);
    rees_dchrg_nem = value(rees_dchrg_nem);
    rees_chrg = value(rees_chrg);
else
    rees_adopt=zeros(1,K);
end

%EES/REES revenue
if island == 0 % If not an island 
    if nopv == 0 % If there's solar 
        pv_nem_revenue=sum(value(pv_nem_revenue));
        pv_w_revenue=sum(value(pv_w_revenue));
        if noees == 0; % And EES/RESS
            rees_revenue=sum(value(rees_revenue));
        else %Or no EES 
            rees_revenue=0;
        end 
    else %If there's no solar 
        if noees == 1 % And no EES/REES
            rees_revenue=0;
        else  % or EES/REES 
            rees_revenue=sum(value(rees_revenue));
        end 
        pv_nem_revenue=0;
        pv_w_revenue=0;
    end 
end 

%Transformer
Pinj = value(Pinj); %Pinj(isnan(Pinj)) = 0; %kW
Qinj = value(Qinj); %Qinj(isnan(Pinj)) = 0; %kVAR
Sinj = sqrt(Pinj.^2 + Qinj.^2); %Absolute value %kVA 
%Sinj = Pinj./cos(atan(Qinj./Pinj)); %kVA %Captures the (+) and (-) flows 
z = value(z);

if opt_t 
    T_rated = value(T_rated);
end 

%Inverter
inv_adopt = value(inv_adopt);
Pinv = value(Pinv); %kW
Qinv = value(Qinv); %kVAR
Sinv = sqrt(Pinv.^2 + Qinv.^2);%Absolute value  %kVA 
%Qanc = value(Qanc); %kVAR
Qind = value(Qind); %kVAR
Qcap = value(Qcap); %kVAR
Qelec = value(Qelec); %kVAR
Qimport = value(Qimport); %kVAR
%Sinv = Pinv./cos(atan(Qinv./Pinv)); %kVA %Captures the (+) and (-) flows 
active = value(active);
active2 = value(active2);

%DLPF
if dlpfc == 1
    %Sflow = Pflow   Theta = value(Theta);
    Volts = value(Volts);
    Pflow = value(Pflow);
    Qflow = value(Qflow);
    Sflow = sqrt(Pflow.^2 + Qflow.^2); %MVA./cos(atan(Qflow./Pflow)); %MVA %Captures +-sign
else
    if lindist == 0
        Theta = zeros(N,T);
        Volts = zeros(N,T);
        Pflow = zeros(B,T);
        Qflow = zeros(B,T);
        Sflow = zeros(B,T);
    end 
end

%LinDist
if lindist  == 1
    Theta = zeros(N,T);
    Volts_sq = value(Volts);
    Volts = sqrt(Volts_sq); %p.u.
    Pflow = value(Pflow);
    Qflow = value(Qflow);
    Sflow = sqrt(Pflow.^2 + Qflow.^2); %MVA
    %Sflow = Pflow./cos(atan(Qflow./Pflow)); %MVA %Captures +-sign
else
    
    if dlpfc == 0
        Theta = zeros(N,T);
        Volts = zeros(N,T);
        Pflow = zeros(B,T);
        Qflow = zeros(B,T);
        Sflow = zeros(B,T); 
    end 
end 