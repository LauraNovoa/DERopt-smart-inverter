
T = length(time); %t-th time interval from 1...T

%% IEEE 33-node test case 
% One node n can take more than one k buildings
% A node n might not have a transformer (slack node)

%% Transformer Map 
% Maps buildings to nodes (transformers)
% This format allows "connecting" multiple buildings to the same node 

%             k1   k2  k3          K   
%T_map(k)= [  n1 | n1 | n1 | ... |   ]; 
%(1,K) 
T_map = [2	3	4	5	6	7	7	8	9	9	10	10	11	12	12	13	13	14	15	15	16	16	17	17	18	18	19	19	20	20	21	21	22	22	23	23	24	24	25	26	26	27	27	28	28	29	29	30	31	31	32	32	33	33];

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
    %(1,N) transformer ratings in kVA, node 1 (slack bus) has 0 kVA rating 
    T_rated = [0 150	100	150	75	75	250	250	75	75	50	75	75	150	75	75	75	100	100	100	100	100	100	500	500	75	75	75	150	250	200	250	75];
       
end 

%% Pinj, Qinj, and Polygon Constraints 
Pinj = sdpvar(T,N,'full'); %kW
Qinj = sdpvar(T,N,'full'); %kVAR 

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
          (Qinj(:,n) == sum(Qimport(:,cluster) + Qind(:,cluster) - Qcap(:,cluster),2)):'Qinj']; %kVAR 
      
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