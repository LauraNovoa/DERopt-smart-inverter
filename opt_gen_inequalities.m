%% General Inequalities
%% Demand Charges
if utility_exists == 1
    dc_count=1;
    for k = 1:K %k loops thru buildings
        
        if dc_exist(k) == 1 % IF that building has demand charges 
            %%Non TOU Demand Charges
            for i=1:length(endpts) %i counts months 
                if i==1 % for January
                    Constraints=[Constraints
                        (import(1:endpts(1),k) <= nontou_dc(i,dc_count)):'nontou_dc (first month)'];
                else % for all other months 
                    Constraints=[Constraints
                        (import(endpts(i-1)+1:endpts(i),k) <= nontou_dc(i,dc_count)):'nontou_dc (other months)'];
                end
            end
                        
            %% TOU Demand Charges (Only during summer months)
          if ~isempty(summer_month) % if we are simulating a summer month
            for i=1:length(summer_month) % i loops through every SUMMER month
                %%%Finding start/finish of each summer month
                if summer_month(i)==1
                    start=1;
                    finish=endpts(summer_month(i));
                else
                    start=endpts(summer_month(i)-1)+1;
                    finish=endpts(summer_month(i));
                end
                
                %%%finding applicable indicies
                %dc_on_index (864x1) flags the intervals in the day that demand charges apply 
                on_index = find(dc_on_index > 0); %(48x1)%returns column array with all days # in the year where dc_on = 1 
                on_index = on_index(find(on_index >= start & on_index < finish)); %returns column array with the day# where dc_on = 1 in the summer month
                
                mid_index = find(dc_mid_index > 0); %(72x1)%returns column array with all days # in the year where dc_mid = 1 
                mid_index = mid_index(find(mid_index >= start & mid_index < finish)); %returns column array with the day# where dc_mid = 1 in the summer month
                
                
                Constraints=[Constraints
                    % For each building k, the import for the days on summer that incur dc 
                    % needs to be <= onpeak_dc [summer_months,sum(dc_exist)] variable 
                    import(on_index,k) <= onpeak_dc(i,dc_count)
                    import(mid_index,k) <= midpeak_dc(i,dc_count)];
            end
          end 
            
            %%%Moving to next DC variable set
            dc_count = dc_count+1;
            
          end
        
    end
end