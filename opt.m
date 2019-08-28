
%% Optimize thru CPLEX
if opt_cplex
    
  % Lower bound & Big M contraints
  Constraints=[Constraints
            0 <= pv_elec
            0 <= pv_nem
            0 <= pv_wholesale
            0 <= pv_adopt <= 99999 %Big M limits
            0 <= nontou_dc
            0 <= onpeak_dc
            0 <= midpeak_dc
            0 <= rees_adopt <= 99999 %Big M limits
            0 <= import
            0 <= rees_chrg
            0 <= rees_dchrg
            0 <= rees_dchrg_nem
            0 <= rees_soc
            0 <= ees_adopt <= 99999 %Big M limits
            0 <= ees_chrg
            0 <= ees_dchrg
            0 <= ees_soc
            0 <= ees_chrg_pv
            0 <= inv_adopt <= 99999
            0 <= Qelec
            0 <= Qimport
            0 <= Qind <= 99999
            0 <= Qcap <= 99999
            0 <= Volts <= 2.0
            -99999 <= Pinv <= 99999
            ];
   
   if opt_t 
       Constraints=[Constraints, 0 <= T_rated <= 20000];
   end 
             
   % Export Model YALMIP -> CPLEX
   tic
   [model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
   elapsed = toc;
   fprintf('Model Export took %.2f seconds \n', elapsed)
  
    options = cplexoptimset;
    options.Display='on';
    options.Diagnostics='on';
    options.TolFun=1e-10;
    cplex = Cplex(model);%instantiate object cplex of class Cplex 
    %cplex.Param.mip.tolerances.mipgap.Cur = 4/100; %Relative MIP Gap
    options.parameter2009 = 0.004;
    
    lb=-1*inf(size(model.f)); 
    ub=inf(size(lb));
    
    fprintf('%s Starting CPLEX Solver \n', datestr(now,'HH:MM:SS'))
    tic
    %[x, fval, exitflag, output, lambda] = cplexlp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, lb, ub, [], options);
    [x, fval, exitflag, output] = cplexmilp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, [],[],[],lb,ub,model.ctype,[],options);
    elapsed = toc;
    fprintf('CPLEX took %.2f seconds \n', elapsed)
    
    output
    exitflag
    fval
    
%     cplex = Cplex(model); %instantiate object cplex of class Cplex 
%     cplex.solve() %metod solve() to create Solution dynamic property
%     cplex.Solution.status
%     cplex.Solution.miprelgap
    
    % Recovering data and assigning to the YALMIP variables
    assign(recover(recoverymodel.used_variables),x)
end

%% Optimize thru YALMIP
if opt_yalmip  
    
% Lower Bound & Big M Constraints  

  Constraints=[Constraints
            0 <= nontou_dc
            0 <= onpeak_dc
            0 <= midpeak_dc
            0 <= import
            0 <= inv_adopt <= 99999
            0 <= Qelec
            0 <= Qimport
            0 <= Qind <= 99999
            0 <= Qcap <= 99999
            0 <= Volts <= 2.0
            -99999 <= Pinv <= 99999
            ];
        
  if isempty(pv_v) ==0
  Constraints=[Constraints
            0 <= pv_elec
            0 <= pv_nem
            0 <= pv_wholesale
            0 <= pv_adopt <= 99999 %Big M limits
 %           3 <= pv_adopt <= 99999 % Limits for semivar
            ];
  end
  
  if isempty(ees_v) ==0
  Constraints=[Constraints
            0 <= rees_adopt <= 99999 %Big M limits
%            13.5 <= rees_adopt <= 99999 %Limits for semivar
            0 <= rees_chrg
            0 <= rees_dchrg
            0 <= rees_dchrg_nem
            0 <= rees_soc 
            0 <= ees_adopt <= 99999 %Big M limits
%            13.5 <= ees_adopt <= 99999 %Limits for semivar
            0 <= ees_chrg
            0 <= ees_chrg_pv
            0 <= ees_dchrg
            0 <= ees_soc
            ];
  end 
        
  if opt_t
       Constraints=[Constraints
          0 <= T_rated <= 20000];
  end 
  
    ops = sdpsettings('solver','cplex','debug',1,'verbose',2,'warning',1,'savesolveroutput',1);
    ops.showprogress=1;
    ops.cplex.options.Display='on';
    ops.cplex.options.Diagnostics='on';
    ops.cplex.mip.tolerances.mipgap = 0.004;
    max_nodes = 60000;
    ops.cplex.MaxNodes=max_nodes;
    ops.cplex.mip.limits.nodes=max_nodes;
    
    %Optimize!
    sol = optimize(Constraints,Objective,ops)
    %sol = optimize(Constraints,[],ops) %remove objective function to debug unfeasible problems 
end