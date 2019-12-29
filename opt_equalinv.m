% If enabled,
% minimize the difference between total reactive power regulation

Q = sdpvar(1,K,'full'); %kVAR
Qdev = sdpvar(K,K,'full'); %kVAR
Qdevp = sdpvar(K,K,'full'); %kVAR
Qdevn = sdpvar(K,K,'full'); %kVAR

%A = inverter incidence matrix (=1 if inverters are adjacent)
A=zeros(K,K);
for i = 1:K
    for j = 1:K
       if abs(T_map(i) - T_map(j)) == 1           
           A(i,j) = 1;
       end
    end
end

%Inverters at the end of the branch 
A(14,11) = 0; A(11,14) = 0;
A(18,30) = 0; A(30,18) = 0;
A(1,29) = 0;A(29,1) = 0;
A(5,25) = 0;A(25,5) = 0;
A(22,8) = 0;A(8,22) = 0;
A(24,19) = 0;A(19,24) = 0;
A(24,28) = 0;A(28,24) = 0;

Constraints = [Constraints 
    %Q == sum(Qind) + sum(Qcap)
    (Q == sum(Qind)):'Equalize Qind'
    (Qdev == repmat(Q,K,1) - repmat(Q',1,K)):'Qdev'
    (Qdev == Qdevp - Qdevn):'Qdevp Qdevn'
    (Qdevp >=0):'Qdevp >=0'
    (Qdevn >=0):'Qdevn >=0 '
    ];

%warning('off','YALMIP:BigM')

for t=1:T
    for k=1:K
    Constraints = [Constraints 
        (implies(Qind(t,k) >= 1, Qcap(t,k) == 0)):sprintf('Qanc/Qind ON OFF  t=%d, k=%d',t,k)
        ];
    end 
end 

if invertermode ~= 1
    if fair
        Objective = Objective + sum(sum(A.*Qdevp)) + sum(sum(A.*Qdevn)); 
    end
end 
