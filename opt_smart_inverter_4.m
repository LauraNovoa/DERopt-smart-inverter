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
              
%This grid kaes a long time
%xi = VV_V1:0.01:VV_V4;
%yi = 0:150:2000;   
    
%xi = VV_V1:0.05:VV_V4;
%yi = 0:200:1000;   
    
%xi = [linspace(VV_V1-0.1,VV_V2,50) 1 linspace(VV_V3,VV_V4+0.1,50)];
xi = linspace(VV_V1-0.1,VV_V4+0.1,60);
yi = linspace(0,1000,6);   

[X,Y] = meshgrid (xi,yi); 

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
      
  figure
  surf(X,Y,Z')
  xlabel('v(x)')
  ylabel('inv_adopt(y)')
  zlabel('Qanc(Z)')     
  
   %slackp = sdpvar(T,K,'full');
   %slackn = sdpvar(T,K,'full');
  
%Changed K to 2 
for k=1:2
   for t=1:T
    
   qanc = interp2(X,Y,Z',Volts(T_map(k),t),inv_adopt(k),'milp');
   %active = binvar(T,K,2); %There are 2 regions : deadband or no deadband
            
   Constraints = [ Constraints
       %(Qanc(t,k) == -1*qanc + slackp(t,k) - slackn(t,k)):sprintf('Qanc = qanc(interp2) t=%d, k=%d',t,k)
       (Qanc(t,k) == -1*qanc):sprintf('Qanc = qanc(interp2) t=%d, k=%d',t,k)
       %(implies( VV_V2 <= Volts(T_map(k),t), Qanc(t,k) == 0 )):['implies VV deadband,t=', num2str(t),', k=', num2str(k)];
       %(implies( Volts(T_map(k),t) <= VV_V3, Qanc(t,k) == 0 )):['implies VV deadband,t=', num2str(t),', k=', num2str(k)];
       %0 <= slackp 
       %0 <= slackn 
       ];  
   
      %(implies(active(t,k,2), [ VV_V2 <= Volts(T_map(k),t) <= VV_V3, Qanc(t,k) == 0 ])):['implies VV 4,t=', num2str(t),', k=', num2str(k)];
      %(sum(active,3) == 1):'VV binary active sum = 1 ' 
             
   end
end

end

%Objective = Objective + sum(sum(slackp)) + sum(sum(slackn));