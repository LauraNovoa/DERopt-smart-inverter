% Lower Bound & Big M Constraints  

  Constraints=[Constraints
            (0 <= nontou_dc):'0 <= nontou_dc'
            (0 <= onpeak_dc):'0 <= onpeak_dc'
            (0 <= midpeak_dc):'0  midpeak_dc'
            (0 <= import):'0 import'
            (0 <= inv_adopt<= 5000):'0 <= inv_adop <= 5000'
            (0 <= Qelec):'0 <= Qelec'
            (0 <= Qimport):'0 <= Qimport'
            (-99999 <= Qanc <= 99999):'-99999 <= Qanc <= 99999'
            %(0 <= Qind <= 99999):'0 <= Qind <= 99999'
            %(0 <= Qcap <= 99999):'0<= Qcap <= 99999'
            (0.5 <= Volts <= 2.0):'0.5 <= Volts <= 2 p.u.'
            (-99999 <= Pinv <= 99999):'-99999 <= Pinv <= 99999 Big M'
            (-99999 <= Qinv <= 99999):'-99999 <= Qinv <= 99999 Big M'
            ];
        
  if isempty(pv_v) ==0
  Constraints=[Constraints
            (0 <= pv_elec):'0 <= pv_elec'
            (0 <= pv_nem):'0 <= pv_nem'
            (0 <= pv_wholesale):'0 <= pv_wholesale'
            %(0 <= pv_adopt <= 99999):'0 <= pv_adopt <= 99999 Big M' %Big M limits
            (0 <= pv_adopt <= 2000):'0 <= pv_adopt <= 99999 Big M' %Big M limits
 %           3 <= pv_adopt <= 99999 % Limits for semivar
            ];
  end
  
  if isempty(ees_v) ==0
  Constraints=[Constraints
            (0 <= rees_adopt <= 99999):' 0 <= rees_adopt <= 99999 Big M' %Big M limits
%            13.5 <= rees_adopt <= 99999 %Limits for semivar
            (0 <= rees_chrg):'0 <= rees_chrg'
            (0 <= rees_dchrg):'0 <= rees_dchrg'
            (0 <= rees_dchrg_nem):'0 <= rees_dchrg_nem'
            (0 <= rees_soc):'0 <= rees_soc' 
            (0 <= ees_adopt <= 99999):'0 <= ees_adopt <= 99999 Big M' %Big M limits
%            13.5 <= ees_adopt <= 99999 %Limits for semivar
            (0 <= ees_chrg):'0 <= ees_chrg'
            (0 <= ees_chrg_pv):'0 <= ees_chrg_pv'
            (0 <= ees_dchrg):'0 <= ees_dchrg'
            (0 <= ees_soc):'0 <= ees_soc'
            ];
 end 
        
  if opt_t
       Constraints=[Constraints
          (0 <= T_rated <= 20000):'0 <= T_rated <= 20000 Big M'];
  end 
  