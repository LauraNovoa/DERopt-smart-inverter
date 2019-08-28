%% General equalities
K = size(elec,2);  %k-th building from 1...K
%% Building Electrical Energy Balances
    Constraints = [Constraints 
        import + pv_elec + ees_dchrg + rees_dchrg == elec + ees_chrg];
    
  Qelec = sdpvar(T,K,'full'); %kVAR
  Qimport = sdpvar(T,K,'full'); %kVAR
  
    Constraints = [Constraints 
        (elec.*repmat(tan(acos(pf)),T,1) == Qimport):'BLDG Q balance' %NO more Qelec
        %(elec.*repmat(tan(acos(pf)),T,1) == Qimport + Qelec):'BLDG Q balance'   
        (Qelec >= 0):'Qelec >=0' 
        (Qimport >= 0):'Qimport >=0' 
        ];

    

%%
%OLD, Non-vectorized
% for k=1:K
%      Constraints = [Constraints 
%         import(:,k) + pv_elec(:,k,:) + ees_dchrg(:,k) + rees_dchrg(:,k) == elec(:,k) + ees_chrg(:,k)];
% end