%Differentiates between smart inverter and opt PQ 
%For SI:
%Prevents curtails at the DC level (equality constraint)
%Allows residential curtailment (Volt-Watt function)

%% PV Constraints
if isempty(pv_v) == 0 
      
     % NEVER curtail PV at the DC level
      %Constraints = [Constraints, (pv_wholesale + pv_elec + ees_chrg_pv + pv_nem + rees_chrg == repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV balance'];   

    if invertermode == 1
        % Do not curtail PV at the DC level
        Constraints = [Constraints, 
            (pv_wholesale + pv_elec + ees_chrg_pv + pv_nem + rees_chrg == repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV balance (No DC curtail)'];   
    else  
        % For SI, Allow PV curtail at the DC level
        Constraints = [Constraints, 
            (pv_wholesale + pv_elec + ees_chrg_pv + pv_nem + rees_chrg <= repmat(solar,1,K).*repmat(pv_adopt,T,1)):'PV balance (DC Curtail)'];
    end 
%% Min PV to adopt: 3 kW
if toolittle_pv ==1 
  for k=1:K
        Constraints = [Constraints, (implies(pv_adopt(k) <= 3, pv_adopt(k) == 0)):'toolittle_pv'];
  end
end 

%% Max PV to adopt (area constrained)
if pv_maxarea 
    maxpv = [1296.193592	220.6164316	17.50637663	209.7896814	227.3885864	489.2995255	58.08934062	198.0385724	251.1221256	573.4781479	1552.421324	646.664299	305.9307368	1010.926181	8.639640818	801.0892088	612.9386393	58.4017605	446.1910585	149.054028	36.89108013	15.02661503	45.03358088	50.34471206	110.9415728	40.88830777	142.2994536	341.1152646	1436.337133	14.54546726	61.91076427];
    Constraints = [Constraints, (pv_adopt <= maxpv):'Mav pv_area'];
end

%% Maximizing solar PV
%Objective = Objective - sum(sum(pv_adopt));

%% Forcing Baseline PV 
if force ==1
    if invertermode == 2 | invertermode == 3
        load('PV1ZNE')
        %load('PV2')
        %load('PV3')
            Constraints = [Constraints, (pv_adopt == PV1ZNE):'Force 1ZNE Baseline PV adoption'];
            %Constraints = [Constraints, (pv_adopt == PV'):'Force Baseline PV adoption'];
            %Constraints = [Constraints, (pv_adopt == PV2'):'Force 2ZNE Baseline PV adoption'];
            %Constraints = [Constraints, (pv_adopt == PV3'):'Force 3ZNE Baseline PV adoption'];
            
    end
end 

%% Don't curtail for residential
% residential = find(strcmp(rate,'R1') |strcmp(rate,'R2') | strcmp(rate,'R3')| strcmp(rate,'R4'));
% 
% Constraints = [Constraints,...
%      ( solar*pv_adopt(residential) ==  pv_wholesale(:,residential) + pv_elec(:,residential) + ees_chrg_pv(:,residential) + pv_nem(:,residential) + rees_chrg(:,residential)):'No residential curtail' ];

%% 
% Limit PV adoption
% pv_limit = 10000; %kW
% Constraints = [Constraints
%               sum(pv_adopt) <= pv_limit];

% Force some PV    
% Constraints=[Constraints
%            sum(pv_adopt) >= 10000 ]
end 