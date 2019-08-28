%% Transformer-Aggregated Nodal Injection
%               n1       n2       
% Pinj(n)= [    :    |   :     };  %[T,N] %kW

%% AEC 31 BLDGS 
% There are more nodes (N=54) than buildings (K=31)
% One node n can take more than one k buildings
% A node n might not have a transformer (connection node)

% Transformer Map - Maps buildings to nodes (transformers)
% This format allows "connecting" multiple buildings to the same node 
%             k1   k2  k3          K   
%T_map(k)= [  n1 | n1 | n1 | ... |   ]; %(1,K)

%T_map = [1 1 1 0 3 0 3 0 9 0 9 0 9 0 13 0 13 0 15 0 25 0 21 0 25 0 27 0 29 0 31 0 2 0 4 0 6 0 8 0 10 0 12 0 14 0 16 0 18 0 20 0 22];
%T_map = [1 1 1 3 3 3 5 5 5 7 7 7 9 9 9 11 11 11 13 13 13 15 15 15 17 17 17 19 19 19 21]; 
%T_map = [2 2 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 44 36 36 38 38 38 54]; %As of Feb.25.19 
T_map = [27	40	28	33	44	37	41	38	35	30	4	2	6	54	18	18	8	22	16	29	34	12	43	11	27	26	39	14	22	42	36]; %Feb.25.19 

%T_rated(1,N) %kVA
%If node has transformer = rating, otherwise = 0 
%T_rated = [0,25,0,25,0,100,0,200,0,100,0,37.5,0,15,0,50,0,25,0,50,0,50,0,15,0,50,0,100,0,25,0,75,0,50,0,150,0,150,0,75,0,50,0,100,0,75,0,100,0,100,0,100,0,100];
%T_rated  = [0,400,0,25,0,100,0,600,0,100,0,37.5,0,15,0,100,0,50,0,50,0,50,0,50,0,50,0,100,0,50,0,75,0,50,0,250,0,150,0,250,0,50,0,100,0,75,0,100,0,100,0,100,0,100];  %As of Feb.25.19
T_rated = [0	150	0	75	0	150	0	75	0	0	75	1000	0	25	0	75	0	50	0	0	0	25	0	0	0	25	25	150	25	300	0	0	25	25	25	25	1500	25	100	1000	200	100	25	25	0	0	0	0	0	0	0	0	0	75]; %Feb.25.19

N = length(T_rated);  %n-th node from 1...N
T = length(time);  %t-th time interval from 1...T

%% New formulation
%Transformer vars
Pinj = sdpvar(T,N,'full'); %kW
Qinj = sdpvar(T,N,'full'); %kVAR 
qimport = sdpvar(T,K,'full'); %kVAR

%Inverter vars
Pinv = sdpvar(T,K,'full'); %kW
Qinv = sdpvar(T,K,'full'); %kVAR
q_elec = sdpvar(T,K,'full'); %kVAR
q_cap = sdpvar(T,K,'full'); %kVAR
q_ind = sdpvar(T,K,'full'); %kVAR
%Sinv_r = sdpvar(1,K,'full'); %kVA %defined in opt_cf


%% Inverter Cost -> Dont forget to add this in opt_cf.m or here

% Sinv_r = sdpvar(1,K,'full');
% 
%     Objective = Objective + inv_v(1)*sum(Sinv_r); %%%Inverter Capital Cost

%% Polygon Approximation
L = 20; % number of line segments of the polygon
i = 0:L-1;
theta = pi/L + i.*(2*pi)./L; %rad.
C = [cos(theta)' sin(theta)'];
sn = T_rated*cos(theta(1));
si = Sinv_r*cos(theta(1));

%Inverter Pinv and Qinv Balance + S constraints for each inverter @ building k, for all T timesteps
Constraints = [ Constraints
    Pinv == - pv_elec - pv_nem - pv_wholesale - ees_dchrg + ees_chrg - rees_dchrg - rees_dchrg_nem; 
    Qinv == - q_elec - q_cap + q_ind;
    C*[reshape(Pinv,1,[]) ; reshape(Qinv,1,[])] <= repelem(si,L,T); %Polygon contraints 
    qimport + q_elec == elec.*repmat(tan(acos(pf)),T,1);            %Building q balance
    qimport <= import.*repmat(tan(acos(pf)),T,1);                   %Limiting qimport to keep building's PF.
    ];
    
    %Trying to minimize qcap that was being produced for no reason
    Objective = [Objective + sum(sum(q_cap))];  

%Inverter dispatch Constraints. So the inverter can't export capacitive and
%import inductive power at the same time.
xcap = binvar(T,K,'full');
xind = binvar(T,K,'full');
Constraints = [ Constraints
    xcap + xind <=1; 
    0 <= q_elec <= xcap.*10000;
    0 <= q_cap <= xcap.*10000;
    0 <= q_ind <= xind.*10000; ];


for n=1:N % For each node n
    cluster = find(T_map == n); % returns vector of building # (k) connected to node n
    if isempty(cluster) == 0 % if there is a building connected to that node, calculate injections and add a constraint     
        
        % Transformer Pinj and Qinj Balance
        Constraints = [Constraints
            Pinj(:,n) ==  sum( import(:,cluster) - pv_nem(:,cluster) - pv_wholesale(:,cluster) - rees_dchrg_nem(:,cluster),2); 
            Qinj(:,n) ==  sum( qimport(:,cluster) - q_cap(:,cluster) + q_ind(:,cluster),2);
            ];
             
        if tc ==1 
            Constraints = [Constraints 
                C*[Pinj(:,n)';Qinj(:,n)'] <= sn(n); %Polygon Constraints 
                %-Pinj(:,n).*repmat(mean(tan(acos(pf(cluster))),2),T,1) <= Qinj(:,n) <= Pinj(:,n).*repmat(mean(tan(acos(pf(cluster))),2),T,1); %Keeping the power factor in the node to be at least the average of the cluster's PF  
                ];
        end 
      
    else % if it i s a connection node, Pinj, Qinj = 0 so it does not show as NaN  
        Pinj(:,n) = zeros(T,1);
        Qinj(:,n) = zeros(T,1);
    end
end