
%% Optimize thru YALMIP
if opt_yalmip  
   
    %Provide x0
    %[model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
    %load('x0')
    %assign(recover(recoverymodel.used_variables),x0)
    %ops = sdpsettings('solver','cplex','debug',1,'verbose',3,'warning',1,'savesolveroutput',1,'usex0',1);
    
    % No x0
    ops = sdpsettings('solver','cplex','debug',1,'verbose',3,'warning',1,'savesolveroutput',1);
    
    ops.showprogress=1;
    %ops.cplex.mip.tolerances.mipgap = 0.004;
    ops.cplex.mip.tolerances.mipgap = 0.04;
    ops.cplex.mip.limits.nodes = 10000;
    ops.cplex.mip.strategy.heuristicfreq = 1;
    %ops.cplex.mip.strategy.probe = 3;
    
    %Optimize!
    %sol = optimize(Constraints,Objective)    %Let YALMIP chose solver
    sol = optimize(Constraints,Objective,ops) %Optimize with CPLEX and options above
    %sol = optimize(Constraints,[],ops)       %Remove objective function to debug unfeasible problems 
end


%% Optimize thru CPLEX
if opt_cplex

    fprintf('%s: Model Export...', datestr(now,'HH:MM:SS'))         
    % Export Model YALMIP -> CPLEX
    tic
    [model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
  
    %save('smart-inverter_R1','model','recoverymodel','diagnostic','internalmodel')
    %load('smart-inverter_R1');
    
    %% CPLEX MATLAB Toolbox options
    options = cplexoptimset;
    options.Display = 'on';
    options.Diagnostics = 'on';       
    options.parameter2009 = 0.004;
    options.MaxNodes = 1000;
    %options.TolFun=1e-10;
    
%% CPLEX class API options

%   cplex = Cplex(model);%instantiate object cplex of class Cplex
%   cplex.Param.mip.limits.nodes.Cur = 2000; %MaxNodes
%   cplex.Param.mip.display.Cur = 4;
%   cplex.Param.mip.tolerances.mipgap.Cur = 0.04; %Relative MIP Gap
    %cplex.Param.preprocessing.presolve.Cur = 0; % Presolve during pre-processing 
    %cplex.Param.preprocessing.relax.Cur = 0; %Presolve the root relaxation 
    %cplex.Param.parallel.Cur = -1 %Opportunistic paralell mode 
    %cplex.Param.lpmethod.Cur = 1 % Use primal simplex for the relaxed LP
    %cplex.Param.lpmethod.Cur = 2 % Use dual simplex for the relaxed LP
    %cplex.Param.lpmethod.Cur = 6 % Use concurrent methods (prima/dual/barrier solve) for the relaxed LP
    %cplex.Param.emphasis.mip.Cur = 1 % emphasis in feasibility over optimality 

    lb=-1*inf(size(model.f)); 
    ub=inf(size(lb));
    
    fprintf('%s: Starting CPLEX Solver \n', datestr(now,'HH:MM:SS'))
    tic
    %[x, fval, exitflag, output, lambda] = cplexlp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, lb, ub, [], options);
    
    %Use Toolbox options
    [x, fval, exitflag, output] = cplexmilp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, [],[],[],lb,ub,model.ctype,[],options);
    
    %No Toolbox options (Class API)
    %[x, fval, exitflag, output] = cplexmilp(model.f, model.Aineq, model.bineq, model.Aeq, model.beq, [],[],[],lb,ub,model.ctype,[]);
    
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
