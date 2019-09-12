%% General equalities
K = size(elec,2);  %k-th building from 1...K

  Qelec = sdpvar(T,K,'full'); %kVAR
  Qimport = sdpvar(T,K,'full'); %kVAR
  
%% Building P Balance %kW
    Constraints = [Constraints 
        (import + pv_elec + ees_dchrg + rees_dchrg == elec + ees_chrg):'BLDG P balance'
        ];
    
 %% Building Q Balance %kVAR
     Constraints = [Constraints 
         (elec.*repmat(tan(acos(pf)),T,1) == Qimport + Qelec):'BLDG Q balance'   
        ];