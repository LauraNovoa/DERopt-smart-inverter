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
    
   s = 10; %number of linearization break points per SI curve segment
   
   xi = linspace(VL,VH,s*5)';
   yi_cap = zeros(length(xi),1);
   yi_ind = zeros(length(xi),1);
   
   for i=1:size(xi,1)
       if xi(i) <= VV_V1
           yi_cap(i) = VV_Q1;
       elseif xi(i) > VV_V1 && xi(i) < VV_V2
           yi_cap(i) = mcap*(xi(i)- VV_V2);
       %elseif xi(i) >= VV_V2 && xi(i) <= VV_V3 %deadband (it is already zero)     
       elseif xi(i) > VV_V3 && xi(i) < VV_V4
           yi_ind(i) = mind*(xi(i)- VV_V3);
       elseif xi(i) >= VV_V4
           yi_ind(i) = VV_Q4;
       end 
   end
   
    figure
    plot(xi,yi_cap); hold on
    plot(xi,yi_ind)
   
    lambda = binvar(s*5,T,'full'); %lambda dimensions: s*5 (5 regions in the SI curve)
    qcap = sdpvar(T,K,'full');
    qind = sdpvar(T,K,'full');
    
    %interp2 lookup
    [X,Y] = meshgrid(VV_Q4:0.1:VV_Q1,0:100:1500);
    Z1sq = (0.5*(X+Y)).^2;
    Z2sq = (0.5*(X-Y)).^2;
    
  for k=1:K
   for t=1:T
    Constraints = [ Constraints
          (sos2(lambda(:,t))):'sos2'
          (Volts(T_map(k),t) == lambda(:,t)'*xi):'Volts = lambda' 
          (qcap(t,k) == lambda(:,t)'*yi_cap):'qcap'
          (qind(t,k) == lambda(:,t)'*yi_ind):'qind'
          (lambda(:,t)>=0):'lambda>=0'
          (sum(lambda(:,t)) == 1):'sum lambda =1' 
          ];
          
       z1sq_cap = interp2(X,Y,Z1sq,qcap(t,k),inv_adopt(k),'sos2');
       z2sq_cap = interp2(X,Y,Z2sq,qcap(t,k),inv_adopt(k),'sos2'); 
       z1sq_ind = interp2(X,Y,Z1sq,qind(t,k),inv_adopt(k),'sos2');
       z2sq_ind = interp2(X,Y,Z2sq,qind(t,k),inv_adopt(k),'sos2'); 
     
   Constraints = [ Constraints
       (Qcap == z1sq_cap - z2sq_cap):'Qcap = z1sq_cap - z2sq_cap'
       (Qind == z1sq_ind - z2sq_ind):'Qind = z1sq_ind - z2sq_ind'
       ];  
           
   end
  end
end
