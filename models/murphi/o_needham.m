Type
    mtype: enum{None, A, B, I, Na, Nb, gD, R};
    proc : enum{none, pi, pres, pini};
    bit  : 0..1;
    byte : 0..255;

    PIni_type : record
        pc     : byte;
        slef   : mtype;
        party  : mtype;
        nonce  : mtype;
        g1     : mtype;
        runable: boolean;
    end;

    PRes_type : record
        pc     : byte;
        slef   : mtype;
        nonce  : mtype;
        g2     : mtype;
        g3     : mtype;
        runable: boolean;
    end;

    PI_type : record
        kNa : boolean;
        kNb : boolean;

        k_Na_Nb__A : boolean;
        k_Na_A__B  : boolean;
        k_Nb__B    : boolean;

        x1 : mtype;
        x2 : mtype;
        x3 : mtype;

        pc       : byte;
        do_enter : boolean;
        runable  : boolean;
    end;

    initial_type : record
        pc      : byte;
        runable : boolean;
    end;

    ca_type : record
        x1   : mtype;
        x2   : mtype;
        PK   : mtype;
        x3   : mtype;
        size : bit;
        send : proc;
    end;

    cb_type : record
        x1   : mtype;
        PK   : mtype;
        x2   : mtype;
        size : bit;
        send : proc;
    end;

Var
    IniRunningAB: boolean;
    IniCommitAB : boolean;
    ResRunningAB: boolean;
    ResCommitAB : boolean;

    ca : ca_type;
    cb : cb_type;

    PI   : PI_type;
    PIni : PIni_type;
    PRes : PRes_type;
    init : initial_type;

    end_PIni : boolean;
    end_PRes : boolean;


function isEmptyCa(): boolean;
begin
    return (ca.size < 1);
end;

function isEmptyCb(): boolean;
begin
    return (cb.size < 1);
end;

function get_ca(): ca_type;
begin
    return ca;
end;

function get_cb(): cb_type;
begin
    return cb;
end;

procedure IniRunning(x: mtype; y: mtype);
begin
    if ((x = A) & (y = B)) then
        IniRunningAB := TRUE;
    endif;
end;

procedure ResRunning(x: mtype; y: mtype);
begin
    if ((x = A) & (y = B)) then
        ResRunningAB := TRUE;
    endif;
end;

procedure IniCommit(x: mtype; y: mtype);
begin
    if ((x = A) & (y = B)) then
        IniCommitAB := TRUE;
    endif;
end;

procedure ResCommit(x: mtype; y: mtype);
begin
    if ((x = A) & (y = B)) then
        ResCommitAB := TRUE;
    endif;
end;

procedure k(x1: mtype);
begin
    if (x1 = Na) then
        PI.kNa := TRUE;
    elsif (x1 = Nb) then
        PI.kNb := TRUE;
    endif;
end;

procedure k2(x1: mtype; x2: mtype);
begin
    if ((x1 = Nb) & (x2 = B)) then
        PI.k_Nb__B := TRUE;
    endif;
end;

procedure k3(x1: mtype; x2: mtype; x3: mtype);
begin
    if ((x1 = Na) & (x2 = A) & (x3 = B)) then
        PI.k_Na_A__B := TRUE;
    elsif ((x1 = Na) & (x2 = Nb) & (x3 = A)) then
        PI.k_Na_Nb__A := TRUE;
    endif;
end;

procedure send_ca(x1: mtype; x2: mtype; PK: mtype; x3: mtype; send: proc);
begin
    ca.x1 := x1;
    ca.x2 := x2;
    ca.PK := PK;
    ca.x3 := x3;

    ca.size := 1;
    ca.send := send;
end;

procedure retrieve_ca();
begin
    ca.x1 := None;
    ca.x2 := None;
    ca.PK := None;
    ca.x3 := None;

    ca.size := 0;
    ca.send := none;
end;

procedure send_cb(x1: mtype; PK: mtype; x2: mtype; send: proc);
begin
    cb.x1 := x1;
    cb.PK := PK;
    cb.x2 := x2;

    cb.size := 1;
    cb.send := send;
end;

procedure retrieve_cb();
begin
    cb.x1 := None;
    cb.PK := None;
    cb.x2 := None;

    cb.size := 0;
    cb.send := none;
end;

procedure unblock_proc(p: proc);
begin
    if (p = pi) then
        PI.runable := TRUE;
    elsif (p = pres) then
        PRes.runable := TRUE;
    elsif (p = pini) then
        PIni.runable := TRUE;
    endif;
end;


startstate
begin
    IniRunningAB := FALSE;
    IniCommitAB  := FALSE;
    ResRunningAB := FALSE;
    ResCommitAB  := FALSE;

    end_PIni := FALSE;
    end_PRes := FALSE;

    PI.pc   := 0;
    PIni.pc := 0;
    PRes.pc := 0;
    init.pc := 0;

    PI.runable   := FALSE;
    PIni.runable := FALSE;
    PRes.runable := FALSE;
    init.runable := TRUE;

    PI.kNa        := FALSE;
    PI.kNb        := FALSE;
    PI.k_Na_Nb__A := FALSE;
    PI.k_Na_A__B  := FALSE;
    PI.k_Nb__B    := FALSE;
    PI.x1         := None;
    PI.x2         := None;
    PI.x3         := None;

    clear ca;
    clear cb;
end;

-- initial process
rule "run PIni(A, I, Na)"
    init.runable = TRUE & init.pc = 0 ==>
begin
    PIni.pc      := 0;
    PIni.slef    := A;
    PIni.party   := I;
    PIni.nonce   := Na;
    PIni.g1      := None;
    PIni.runable := TRUE;

    init.pc := init.pc + 1;
end;

rule "run PIni(A, B, Na)"
    init.runable = TRUE & init.pc = 0 ==>
begin
    PIni.pc      := 0;
    PIni.slef    := A;
    PIni.party   := B;
    PIni.nonce   := Na;
    PIni.g1      := None;
    PIni.runable := TRUE;

    init.pc := init.pc + 1;
end;

rule "run PRes(B, Nb)"
    init.runable = TRUE & init.pc = 1 ==>
begin
    PRes.pc      := 0;
    PRes.slef    := B;
    PRes.nonce   := Nb;
    PRes.g2      := None;
    PRes.g3      := None;
    PRes.runable := TRUE;

    init.pc := init.pc + 1;
end;

rule "run PI()"
    init.runable = TRUE & init.pc = 2 ==>
begin
    PI.pc       := 0;
    PI.do_enter := FALSE;
    PI.runable  := TRUE;

    init.runable := FALSE;
end;

-- PIni

rule "PIni atomic 1"
    PIni.runable = TRUE & PIni.pc = 0 & isEmptyCa() = TRUE ==>
begin
    IniRunning(PIni.slef, PIni.party);
    send_ca(PIni.slef, PIni.nonce, PIni.slef, PIni.party, pini);
    PIni.pc := 2;
    PIni.runable := FALSE;
end;

rule "PIni atomic 2"
    PIni.runable = TRUE & PIni.pc = 2 & isEmptyCa() = FALSE & isEmptyCb() = TRUE ==>
    var message: ca_type;
begin
    message := get_ca();
    if ((PIni.slef = message.x1) &
        (PIni.nonce = message.x2) &
        (PIni.slef = message.x3)
    ) then
        retrieve_ca();

        -- unblock sender process
        unblock_proc(message.send);

        PIni.g1 := message.PK;
        IniCommit(PIni.slef, PIni.party);
        send_cb(PIni.slef, PIni.g1, PIni.party, pini);
        PIni.runable := FALSE;

        end_PIni := TRUE;
    endif;
end;

-- PRes

rule "PRes atomic 1"
    PRes.runable = TRUE & PRes.pc = 0 & isEmptyCa() = FALSE ==>
    var message: ca_type;
begin
    message := get_ca();
    if ((PRes.slef = message.x1) & (PRes.slef = message.x3)) then
        retrieve_ca();
        unblock_proc(message.send);
        PRes.g2 := message.x2;
        PRes.g3 := message.PK;
        ResRunning(PRes.g3, PRes.slef);
        send_ca(PRes.slef, PRes.g2, PRes.nonce, PRes.g3, pres);
        PRes.pc := 2;
        PRes.runable := FALSE;
    endif;
end;

rule "PRes atomic 2"
    PRes.runable = TRUE & PRes.pc = 2 & isEmptyCb() = FALSE ==>
    var message: cb_type;
begin
    message := get_cb();
    if ((PRes.slef = message.x1) &
        (PRes.nonce = message.PK) &
        (PRes.slef = message.x2)
    ) then
        retrieve_cb();

        unblock_proc(message.send);

        ResCommit(PRes.g3, PRes.slef);
        PRes.runable := FALSE;

        end_PRes := TRUE;
    endif;
end;

-- PI

rule "ca ! B, gD, A, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, gD, A, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, gD, B, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, gD, B, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, gD, I, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, gD, I, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, A, A, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, A, A, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, A, B, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, A, B, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, A, I, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, A, I, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, B, A, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, B, A, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, B, B, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, B, B, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, B, I, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, B, I, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, I, A, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, I, A, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, I, B, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, I, B, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, I, I, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, I, I, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! B, gD, B, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(B, gD, B, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNa -> A : R), Na, Na, A"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNa) ? A : R, Na, Na, A, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (((kNa && kNb) || k_Na_Nb__A) -> A : R), Na, Nb, A"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(((PI.kNa & PI.kNb) | PI.k_Na_Nb__A) ? A : R, Na, Nb, A, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (((kNa && kNb) || k_Na_Nb__A) -> A : R), Na, Nb, A"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(((PI.kNa & PI.kNb) | PI.k_Na_Nb__A) ? A : R, Na, Nb, A, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNa -> A : R), Na, gD, A"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNa) ? A : R, Na, gD, A, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNa -> A : R), Na, A, A"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNa) ? A : R, Na, A, A, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNa -> A : R), Na, B, A"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNa) ? A : R, Na, B, A, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNa -> A : R), Na, I, A"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNa) ? A : R, Na, I, A, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! ((kNa || k_Na_A__B) -> B : R), Na, A, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca(((PI.kNa | PI.k_Na_A__B) ? B : R), Na, A, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNa -> B : R), Na, B, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNa ? B : R), Na, B, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNa -> B : R), Na, I, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNa ? B : R), Na, I, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNb -> B : R), Nb, A, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNb ? B : R), Nb, A, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNb -> B : R), Nb, B, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNb ? B : R), Nb, B, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "ca ! (kNb -> B : R), Nb, I, B"
    PI.runable = TRUE & isEmptyCa() = TRUE & PI.pc = 0 ==>
begin
    send_ca((PI.kNb ? B : R), Nb, I, B, pi);
    -- PI.pc := 1;
    PI.runable := FALSE;
end;

rule "cb ! ((k_Nb__B || kNb) -> B : R), Nb, B"
    PI.runable = TRUE & isEmptyCb() = TRUE & PI.pc = 0 ==>
begin
    send_cb(((PI.k_Nb__B | PI.kNb) ? B : R), Nb, B, pi);
    -- PI.pc := 2;
    PI.runable := FALSE;
end;

rule "d_step"
    PI.runable = TRUE & isEmptyCa() = FALSE & PI.pc = 0 ==>
    var message: ca_type;
begin
    message := get_ca();
    retrieve_ca();

    unblock_proc(message.send);

    PI.x1 := message.x2;
    PI.x2 := message.PK;
    PI.x3 := message.x3;

    if (PI.x3 = I) then
        k(PI.x1);
        k(PI.x2);
    else
        k3(PI.x1, PI.x2, PI.x3);
    endif;

    PI.x1 := None;
    PI.x2 := None;
    PI.x3 := None;
end;

rule "d_step 2"
    PI.runable = TRUE & isEmptyCb() = FALSE & PI.pc = 0 ==>
    var message: cb_type;
begin
    message := get_cb();
    retrieve_cb();

    unblock_proc(message.send);

    PI.x1 := message.PK;
    PI.x2 := message.x2;

    if (PI.x2 = I) then
        k(PI.x1);
    else
        k2(PI.x1, PI.x2);
    endif;

    PI.x1 := None;
    PI.x2 := None;
end;

-- invariant "[] (([] !(p)) || (!(p) U (q)))"
--     (!ResCommitAB) | (  (!ResCommitAB & !IniRunningAB) 
--                       | (ResCommitAB & IniRunningAB)
--                     )

invariant "[] (([] !(p)) || (!(p) U (q)))"
     (!IniCommitAB) | (  (!IniCommitAB & !ResRunningAB) 
                       | ( IniCommitAB & ResRunningAB)
                     )

-- invariant "G F (IniCommitAB & IniRunningAB & ResCommitAB & ResRunningAB)"
--     !(PIni.runable | PRes.runable | PI.runable | init.runable) -> (end_PIni & end_PRes)