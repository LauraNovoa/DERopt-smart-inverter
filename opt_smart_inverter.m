%% Volt-Var curve
VV_V1 = 0.9;
VV_V2 = 0.97;
VV_V3 = 1.03;
VV_V4 = 1.1;
VV_Q1 = 0.44;
VV_Q2 = 0;
VV_Q3 = 0;
VV_Q4 = -0.44;

mcap = (VV_Q2 - VV_Q1)/(VV_V2 - VV_V1);
mind = (VV_Q4 - VV_Q3)/(VV_V4 - VV_V3);

active = binvar(T,K,5); %There are 5 regions in the VV curve

Constraints = [ Constraints, (sum(active,3) == 1):'VV active binary'];

warning('off','YALMIP:strict') 

for k = 1:K
  tic;
    for t = 1:T
        Constraints = [ Constraints, 
                        (implies(active(t,k,1), [  Volts(T_map(k),t) <= VV_V1, Qcap(t,k) == VV_Q1*inv_adopt(k) ])):['implies VV 1,t=', num2str(t),', k=', num2str(k)]; 
                        (implies(active(t,k,2), [     Volts(T_map(k),t) >= VV_V4, Qind(t,k) == VV_Q4*inv_adopt(k) ])):['implies VV 2,t=', num2str(t),', k=', num2str(k)];
                        (implies(active(t,k,3), [ VV_V3 < Volts(T_map(k),t) < VV_V4, Qind(t,k) == mind*(Volts(T_map(k),t)-0.97)])):['implies VV 3,t=', num2str(t),', k=', num2str(k)];
                        (implies(active(t,k,4), [ VV_V2 <= Volts(T_map(k),t) <= VV_V3, Qind(t,k) == 0, Qcap == 0 ])):['implies VV 4,t=', num2str(t),', k=', num2str(k)];
                        (implies(active(t,k,5), [   VV_V1 < Volts(T_map(k),t) < VV_V2, Qcap(t,k) == mcap*(Volts(T_map(k),t)- 1.03)])):['implies VV 5,t=', num2str(t),', k=', num2str(k)];
                      ];
    end
   vvark = toc; 
end

%% Volt-Watt 
VW_V1 = 1;
VW_V2 = 0.93;
VW_V3 = 1.06;
VV_P1 = 1;
VV_P2 = 1;
VV_P3 = 0;

mvw =  (VV_P3 - VV_P2) /  (VW_V3 - VW_V2 );

active2 = binvar(T,K,2); %We have 2 other regions in the VW curve

Constraints = [ Constraints, (sum(active2,3) == 1):'VW active binary'];
for k = 1:K
    tic;
    %First region 
    Constraints = [Constraints, (Pinv(:,k) <= inv_adopt(k)):['VW region 1, k=',num2str(k)]];   
    for t = 1:T      
        Constraints = [ Constraints, sum(active2,3) == 1,
                        (implies(active2(t,k,1), [ VV_V2 < Volts(T_map(k),t) < VV_V3, Pinv(t,k) <= mvw*(Volts(T_map(k),t)-1.06) ])):['implies VW 2,t=', num2str(t),', k=', num2str(k)];
	                    (implies(active2(t,k,2), [    Volts(T_map(k),t) > VV_V3, Pinv(t,k) == 0 ])):['implies VW 3,t=', num2str(t),', k=', num2str(k)];
                      ];
    end 
    vwattk = toc;
end 
