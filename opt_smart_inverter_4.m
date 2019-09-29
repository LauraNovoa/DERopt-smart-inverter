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
              
%This grid takes a long time
%xi = VV_V1:0.01:VV_V4;
%yi = 0:150:2000;   
    
%xi = VV_V1:0.05:VV_V4;
%yi = 0:200:1000;   
    
%xi = linspace(VV_V1-0.1,VV_V4+0.1,60); % this works but precision is not good

% xi = [linspace(VV_V1-0.1,VV_V2-.001,20) linspace(VV_V2,VV_V3,20) linspace(VV_V3+.001,VV_V4+0.1,50)];
% yi = linspace(0,1000,6);

%Coarse mesh
% xi = [linspace(VV_V1-0.1,VV_V2-.001,2) linspace(VV_V2,VV_V3,2) linspace(VV_V3+.001,VV_V4+0.1,2)];
% yi = linspace(0,4000,3);

%SI points mesh
xi = [VV_V1-0.1 VV_V1 VV_V2 VV_V3 VV_V4 VV_V4+0.1]
yi = linspace(0,2500,2)

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
 
%Choose bldgs to have Smart Inverters
%bldg = [1 2];
%bldg = [1 2 10 12 22]
bldg = [1 5 6 10 12]
%bldg = [1 2 4 6 10 12 15 17 19 22 23 25 29 30 31];
  
for k=1:length(bldg) % will only add constraints to the buildings listed in 'bldg' vector
   for t=1:T
    
   qanc = interp2(X,Y,Z',Volts(T_map(bldg(k)),t),inv_adopt(bldg(k)),'milp');
          
   Constraints = [ Constraints
       %(Qanc(t,k) == -1*qanc + slackp(t,k) - slackn(t,k)):sprintf('Qanc = qanc(interp2) t=%d, k=%d',t,k)
       (Qanc(t,bldg(k)) == -1*qanc):sprintf('Qanc = qanc(interp2) t=%d, k=%d',t,bldg(k))
       ];  
              
   end
end

%  Constraints = [ Constraints
%        (0 <= slackp ):'slackp >=0'
%        (0 <= slackn ):'slackn >=0' 
%        ];

% Objective = Objective + sum(sum(slackp)) + sum(sum(slackn));

end

%% Keep voltage close to 1 p.u. 

tt = sdpvar(N,T,'full');

Objective = Objective + sum(sum(tt));

Constraints = [Constraints
    (tt >= (1-Volts)):'tt >= 1-Volts'
    (tt >= -(1-Volts)):'tt >= -(1-Volts)'
    ];

%% Keep inv_adopt close to polygon limit

% ii = sdpvar(K,T,'full');
% 
% Objective = Objective + sum(sum(ii));
% 
% for k=1:K %for each bldg
% Constraints = [Constraints
%     (ii(k) >= (s(k) - C*[Pinv(:,k)';Qinv(:,k)'])):'ii >= s - (...)' 
%     (ii(k) >= -(s(k) - C*[Pinv(:,k)';Qinv(:,k)'])):'ii >= s - (...)'
%     ];
% end

%% Penalty for oversizing inverter 

% ii = sdpvar(T,K,'full');
% 
% for t=1:T
%     for k=1:K %for each bldg
%         Objective = Objective + sum(sum(ii(t,k)));
%         Constraints = [Constraints 
%             ii(t,k) >=  (s(k) - C*[Pinv(t,k)';Qinv(t,k)])'ii >= s - (...)' 
%             ii(t,k) >= -(s(k) - C*[Pinv(t,k)';Qinv(t,k)])'ii >= - (s - (...))' 
%             ];
%     end
% end 