% If enabled,
% minimize the difference between total reactive power absorbed by all inverters

Q = sdpvar(1,K,'full'); %kVAR
Qdev = sdpvar(K,K,'full'); %kVAR
Qdevp = sdpvar(K,K,'full'); %kVAR
Qdevn = sdpvar(K,K,'full'); %kVAR

Constraints = [Constraints 
    %Q == sum(Qind) + sum(Qcap)
    (Q == sum(Qind)):'Equalize only Qind'
    (Qdev == repmat(Q,K,1) - repmat(Q',1,K)):'Qdev'
    (Qdev == Qdevp - Qdevn):'Qdevp Qdevn'
    (Qdevp >=0):'Qdevp >=0'
    (Qdevn >=0):'Qdevn >=0 '
    ];

warning('off','YALMIP:BigM')

for t=1:T
    for k=1:K
    Constraints = [Constraints 
        (implies(Qind(t,k) >= 1, Qcap(t,k) == 0)):sprintf('Qanc/Qind ON OFF  t=%d, k=%d',t,k)
        ];
    end 
end 

if invertermode ~= 1
    if equalqinv
        Objective = Objective + sum(sum(Qdevp)) + sum(sum(Qdevn)); 
    end
end 
