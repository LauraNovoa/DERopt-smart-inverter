
%% Optimize thru CPLEX
if opt_cplex
            
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
   
    ops = sdpsettings('solver','cplex','debug',1,'verbose',2,'warning',1,'savesolveroutput',1);
    ops.showprogress=1;
    ops.cplex.options.Display='on';
    ops.cplex.options.Diagnostics='on';
    ops.cplex.mip.tolerances.mipgap = 0.004;
    ops.cplex.MaxNodes=60000;
    ops.cplex.mip.limits.nodes=60000;
    
    %Optimize!
    sol = optimize(Constraints,Objective,ops)
    %sol = optimize(Constraints,[],ops) %remove objective function to debug unfeasible problems 
end