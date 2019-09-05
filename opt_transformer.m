
T = length(time); %t-th time interval from 1...T

%% AEC 31 Buildings
% There might be more nodes (n) than buildings (k) 
% One node n can take more than one k buildings
% A node n might not have a transformer (connection node)

%% Transformer Map 
% Maps buildings to nodes (transformers)
% This format allows "connecting" multiple buildings to the same node 

%             k1   k2  k3          K   
%T_map(k)= [  n1 | n1 | n1 | ... |   ]; %(1,K)

%% Transformer Ratings
%% Optimize Transformer Ratings
if opt_t
    
    T_rated = sdpvar(1,N,'full');  %T_rated as decision variable 
  
    Objective = Objective + xfmr_v(1)*sum(T_rated); %Add to objective transformer cost to objective function

    %T_rated can only assume a list of possible values
    possiblevalues = [0,10,15,25,37.5,50,75,100,167,200,225,300,500,750,1000,1500,2000,3000,4000,5000,6000,7000,10000,20000];

    %Option (1) Use ismember (it is slower than methods below)
    %Constraints = [Constraints, ismember(T_rated,possiblevalues)];

    % Option (2) Use binvar 
    %  pick = binvar(54,length(possiblevalues),'full');
    %  Constraints = [Constraints 
    %      (T_rated' == (pick*possiblevalues')):'PickPossiblevalues' 
    %      (sum(pick,2)==1):'SumPick=1' 
    %      (T_rated >=0):'T_rated>0' ]

    %Option (3) Use sdpvar and binary()
    pick = sdpvar(N,length(possiblevalues),'full');
    Constraints = [Constraints
        (T_rated' == (pick*possiblevalues')):'opt T_rated, pick*possiblevalues'
        (binary(pick)):'opt T_rated, binary(pick)'
        sum(pick,2)==1 ];

%% Known transformer ratings   
else
    
    ratings = [1250	37.5	150	25	250	1500	25	150	37.5	100	500	150	75	200	25	200	150	25	100	37.5	37.5	25	75	37.5	100	50	100	150	1000	25	25]; %Apr.10.19
    
    T_rated = zeros(1,N);
    for k=1:K
        T_rated(T_map(k)) = ratings(k);
    end  
end 

%% Pinj, Qinj, and Polygon Constraints 
Pinj = sdpvar(T,N,'full'); %kW
Qinj = sdpvar(T,N,'full'); %kVAR 
Pinj_in = sdpvar(T,N,'full'); %kW
Qinj_in = sdpvar(T,N,'full'); %kVAR

%Transformer Polygon Constraints
L = 20; % number of line segments of the polygon
i = 0:L-1;
theta = pi/L + i.*(2*pi)./L; %rad
C = [cos(theta)' sin(theta)'];
s = T_rated*cos(theta(1));

%Define P and Q flows thru XFMR (Pinj and Qinj)
for n=1:N % For each node n
    cluster = find(T_map == n); % return vector of building # (k) connected to node n
    if isempty(cluster) == 0    % if node n is a XFMR node (there is a building connected to that node) calculate P and Q injections
      
      Constraints = [Constraints 
          (Pinj(:,n) == sum(import(:,cluster) - pv_nem(:,cluster) - pv_wholesale(:,cluster) - rees_dchrg_nem(:,cluster),2)):'Pinj'
          (Pinj_in(:,n) == sum(import(:,cluster),2)):'Pinj_in'
          (Qinj(:,n) == sum(Qimport(:,cluster) + Qind(:,cluster) - Qcap(:,cluster),2)):'Qinj'
          (Qinj_in(:,n) == sum(Qimport(:,cluster) + Qind(:,cluster),2)):'Qinj_in']; %kVAR 
      
        if tc ==1 %Add transformer kVA rating polygon constraint 
            Constraints = [Constraints, (C*[Pinj(:,n)';Qinj(:,n)'] <= alpha*s(n)):'Transformer Polygon'];
            Constraints = [Constraints, (sum(import(:,cluster),2) <= alpha*T_rated(n)):'Transformer IN Limit'];
            Constraints = [Constraints, (sum(pv_nem(:,cluster),2) + sum(pv_wholesale(:,cluster),2) + sum(rees_dchrg_nem(:,cluster),2)  <= alpha*T_rated(n)):'Transformer OUT Limit'];
        end 
      
    else % if connection node, Pinj, Qinj = 0 (so it does not show solution as NaN)
        Pinj(:,n) = zeros(T,1);
        Qinj(:,n) = zeros(T,1);
    end
end

%% Fixing min power factor at the transformer
% Just so Qimport is not too large 

if minpf == 1
    
    PFmin = 0.9;
    mm = -T_rated ;
    MM = T_rated ; 

    z = binvar(size(Qinj,1),size(Qinj,2),'full');

    Constraints = [Constraints, 
%       (z*repmat(mm,N,1) <= Qinj <= (1-z)*repmat(MM,N,1)):'Min PF 1'
%       (tan(PFmin)*Pinj + (1-z)*repmat(mm,N,1) <= Qinj <= tan(PFmin)*Pinj + z*repmat(MM,N,1)):'Min PF 2'
        (z*repmat(mm,N,1) <= Qinj_in <= (1-z)*repmat(MM,N,1)):'Min PF 1'
        (tan(PFmin)*Pinj_in + (1-z)*repmat(mm,N,1) <= Qinj_in <= tan(PFmin)*Pinj_in + z*repmat(MM,N,1)):'Min PF 2'
        ];
    
end 