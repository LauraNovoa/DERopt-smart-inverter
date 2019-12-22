%Minimize the deviation between reactive power absorbed/injected by all buildings. 

Q = sdpvar(1,K,'full'); %kVAR
Qdev = sdpvar(K,K,'full'); %kVAR
Qdevp = sdpvar(K,K,'full'); %kVAR
Qdevn = sdpvar(K,K,'full'); %kVAR

Constraints = [Constraints 
    Q == sum(Qind) + sum(Qcap)
    Qdev == repmat(Q,K,1) - repmat(Q',1,K)
    Qdev == Qdevp - Qdevn
    Qdevp >=0
    Qdevn >=0
    ];

if equalqinv
Objective = Objective + sum(sum(Qdevp)) + sum(sum(Qdevn)); 
end
