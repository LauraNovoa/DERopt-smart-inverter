%Qanc
%manual interp2 

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
             
    %xi = VV_V1:0.01:VV_V4;
    %yi = 0:150:2000;   
    
    xi = VV_V1:0.1:VV_V4;
    yi = 0:100:1000;   

   %lookup
   for j=1:length(yi)
       for i=1:length(xi)
            if xi(i) <= VV_V1
               Z(i,j) = VV_Q1*yi(j);
            elseif xi(i) > VV_V1 && xi(i) < VV_V2
               Z(i,j) = mcap*(xi(i)- VV_V2)*yi(j);
            elseif xi(i) >= VV_V2 && xi(i) <= VV_V3 %deadband
               Z(i,j) = 0;
            elseif xi(i) > VV_V3 && xi(i) < VV_V4
               Z(i,j) = mind*(xi(i)- VV_V3)*yi(j);
            elseif xi(i) >= VV_V4
               Z(i,j) = VV_Q4*yi(j);
            end
       end
   end
  
  surf(Z)
  xlabel('v(x)')
  ylabel('inv_adopt(y)')
  zlabel('Qanc(Z)')
   
    n = length(xi)
    m = length(yi)
    alpha = binvar(n,T,K,'full'); 
    beta = binvar(m,T,K,'full');
    h = binvar(size(lambda,1)-1,T,K,'full'); 
    
    qanc = sdpvar(T,K,'full');
  
    for k=1:K
        for t=1:T
    
        Constraints = [ Constraints
          (sum(alpha(:,t,k)) == 1):'sum alpha =1'
          (alpha(:,t,k)>=0):'lambda>=0'
          (sum(h(:,t,k)) == 1):'sum h = 1' 
          (Volts(T_map(k),t) == alpha(:,t,k)'*xi):'Volts = alpha*xi' 
          (inv_adopt(k) <= beta(:,t,k)'*yi):''
          (inv_adopt(k) >= beta(:,t,k)'*yi):''
          (sum(beta(:,t,k)) == 1):'sum beta = 1'
           qanc(t,k) <= 
    
         ];
     
     %maual alpha SOS2
     for i = i:n
         if i==1 
                Constraints = [ Constraints
                (alpha(i,t,k)<= h(i,t,k)):'lambda <=  h(i)'
                ];
         elseif i==n
                Constraints = [ Constraints
                (alpha(i,t,k)<= h(i-1,t,k)):'lambda <= h(i-1))'
                ];
         else 
                Constraints = [ Constraints
                (alpha(i,t,k)<= h(i-1,t,k)+h(i,t,k)):'lambda <= h(i-1) + h(i)'
                ];
         end
     end  

     
     
     
   Constraints = [ Constraints
       (Qanc(t,k) == -1*qanc ):sprintf('Qanc = qanc(interp2) t=%d, k=%d',t,k)
       ];  
           

end
