%%%NEM Constraints - Limits NEM imports by quantity and credits for imported electricity

%%%If nem_c = 1, Apply NEM and ZNE Constraints
if nem_c == 1
    for k=1:K
        %%%Current Utility Rate
        index=find(ismember(rate_labels,rate(k)));
        
        %%%NEM (+wholesale) Credits to be less than Import Cost

        %Constraints = [Constraints
            %(export_price(:,index)'*(rees_dchrg_nem(:,k)+pv_nem(:,k)) <= import_price(:,index)'*import(:,k)):'NEM credits < Import Cost'];
        
        %Constraints = [Constraints
            %(sum(ex_wholesale*pv_wholesale(:,k)) <= 2*import_price(:,index)'*import(:,k)):'NEM credits < Import Cost'];

         Constraints = [Constraints
            (export_price(:,index)'*(rees_dchrg_nem(:,k)+pv_nem(:,k)) + (sum(ex_wholesale*pv_wholesale(:,k)))<= import_price(:,index)'*import(:,k)):'NEM credits < Import Cost'];

        if net_import_on == 1
        %%% Export to be always greater than a percentage of import. Export >= zne*import
        %%% zne = 1 for full ZNE.

            if nem_annual == 1 
               %%% Calculated annually  
                Constraints=[Constraints
                     %sum(sum(pv_nem)) + sum(sum(pv_wholesale)) + sum(sum(rees_dchrg_nem)) >= zne.*sum(sum(import))];
                     (sum(sum(pv_nem)) + sum(sum(pv_wholesale)) + sum(sum(rees_dchrg_nem)) >= zne.*sum(sum(import)) + sum(ees_soc(1,:)+ rees_soc(1,:))):'ZNE Annual: Import + SOC <= Export'];
            end
            
            if nem_montly == 1 &&  nem_annual == 0      
                %%%Montly NEM export to import for each building k
                %%%Renewable fraction = 1 -> 100% load met with renewable
                for j = 1:length(endpts) %for each month
                    if j == 1 %Jan
                        st=1;
                        fn=endpts(1);
                    elseif j == length(endpts) %Dec
                        st=endpts(j-1)+1;
                        fn=size(elec,1);
                    else
                        st=endpts(j-1)+1;
                        fn=endpts(j);
                    end

                    Constraints = [Constraints
                        sum(pv_nem(st:fn,k)+ pv_wholesale(st:fn,k))+ rees_dchrg_nem(st:fn,k) >= zne.*sum(import(st:fn,k))];
                end
            end
        end
    end
end

%% Grid import Limit (total kWh)
if grid_import_on == 1 
    Constraints=[Constraints
        sum(sum(import)) <= import_limit.*sum(sum(elec))];
end

%% Island  (open the breaker!) 
if island ==1
   Constraints = [Constraints 
       sum(import,2) == sum(pv_nem,2) + sum(pv_wholesale,2) + sum(rees_dchrg_nem,2)];
   
end