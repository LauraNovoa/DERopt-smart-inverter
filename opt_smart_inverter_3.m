%Qanc
%% Volt-Var curve with deadband 
if VV
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
    
   s = 10; %number of piecewise-linearization breakpoints (per si curve segment)
   xi = linspace(VL,VH,s*5)';
   yi = zeros(length(xi),1);
   
   %interp1 lookup
   for i=1:size(xi,1)
       if xi(i) <= VV_V1
           yi(i) = VV_Q1;
       elseif xi(i) > VV_V1 && xi(i) < VV_V2
           yi(i) = mcap*(xi(i)- VV_V2);
       %elseif xi(i) >= VV_V2 && xi(i) <= VV_V3 %deadband (it is already zero)     
       elseif xi(i) > VV_V3 && xi(i) < VV_V4
           yi(i) = mind*(xi(i)- VV_V3);
       elseif xi(i) >= VV_V4
           yi(i) = VV_Q4;
       end 
   end
   
    figure
    plot(xi,yi)
   
    lambda = binvar(s*5,T,K,'full'); %lambda dimensions: s*5 (5 regions in the SI curve)
    h = binvar(size(lambda,1)-1,T,K,'full'); 
    qanc = sdpvar(T,K,'full');
    
%   lambda2 = binvar(length(xxi),T,'full');
    
    %interp2 lookup
    [X,Y] = meshgrid(VV_Q4:0.1:VV_Q1,0:150:2000);
    Z1sq = (0.5*(X+Y)).^2;
    Z2sq = (0.5*(X-Y)).^2;
        
  for k=1:K
   for t=1:T
    Constraints = [ Constraints
          %(sos2(lambda(:,t,k))):'sos2 lambda'
          (sum(h(:,t,k)) == 1):'sum h = 1' 
          (Volts(T_map(k),t) == lambda(:,t,k)'*xi):'Volts = lambda' 
          (qanc(t,k) == lambda(:,t,k)'*yi):'qanc'
          (lambda(:,t,k)>=0):'lambda>=0'
          (sum(lambda(:,t,k)) == 1):'sum lambda =1' 
         ];
     
     %maual SOS2
     for i = i:size(lambda,1)
         if i==1 
                Constraints = [ Constraints
                (lambda(i,t,k)<= h(i,t,k)):'lambda <=  h(i)'
                ];
         elseif i==size(lambda,1)
                Constraints = [ Constraints
                (lambda(i,t,k)<= h(i-1,t,k)):'lambda <= h(i-1))'
                ];
         else 
                Constraints = [ Constraints
                (lambda(i,t,k)<= h(i-1,t,k)+h(i,t,k)):'lambda <= h(i-1) + h(i)'
                ];
         end
     end
          
      %q = interp1(xi,yi,Volts(T_map(k),t),'sos2');
      %Constraints = [Constraints, qanc(t,k) == q];
      
%     Constraints = [ Constraints
%      (sos2(lambda2(:,t))):'sos2 lambda2'
%      (sum(lambda(:,t)) == 1):'sum lambda2 =1'
%      (Volts(T_map(k),t) == lambda(:,t)'*X):'Volts = lambda'  
     
      z1sq = interp2(X,Y,Z1sq,qanc(t,k),inv_adopt(k),'sos2');
      z2sq = interp2(X,Y,Z2sq,qanc(t,k),inv_adopt(k),'sos2');
          
   Constraints = [ Constraints
       (Qanc(t,k) == z1sq - z2sq):sprintf('Qanc = z1sq - z2sq = qanc*inv_adopt, t=%d, k=%d',t,k)
       %(Qcap(t,k) == z1sq_cap - z2sq_cap):'Qcap = z1sq_cap - z2sq_cap'
       %(Qind(t,k) == z1sq_ind - z2sq_ind):'Qind = z1sq_ind - z2sq_ind'
       ];  
           
   end
  end
end
