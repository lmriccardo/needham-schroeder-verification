mtype = {None, A, B, I, Na, Nb, gD, R};

#define IniRunning(x, y) if                                          \
                         :: ((x == A) && (y == B)) -> IniRunningAB = 1 \
                         :: else skip                                \
                         fi

#define IniCommit(x, y) if                                          \
                        :: ((x == A) && (y == B)) -> IniCommitAB = 1 \
                        :: else skip                                \
                        fi

#define ResRunning(x, y) if                                          \
                         :: ((x == A) && (y == B)) -> ResRunningAB = 1 \
                         :: else skip                                \
                         fi

#define ResCommit(x, y) if                                          \
                        :: ((x == A) && (y == B)) -> ResCommitAB = 1 \
                        :: else skip                                \
                        fi

#define k(x1)          if                       \
                       :: (x1 == Na) -> kNa = 1 \
                       :: (x1 == Nb) -> kNb = 1 \
                       :: else skip             \
                       fi

#define k2(x1, x2)     if                                      \
                       :: (x1 == Nb && x2 == B) -> k_Nb__B = 1 \
                       :: else skip                            \
                       fi

#define k3(x1, x2, x3) if                                                     \
                       :: (x1 == Na && x2 == A  && x3 == B) -> k_Na_A__B  = 1 \
                       :: (x1 == Na && x2 == Nb && x3 == A) -> k_Na_Nb__A = 1 \
                       :: else skip                                           \
                       fi


chan ca = [0] of {mtype, mtype, mtype, mtype};
chan cb = [0] of {mtype, mtype, mtype}

bit IniCommitAB  = 0;
bit IniRunningAB = 0;
bit ResRunningAB = 0;
bit ResCommitAB  = 0;

// hidden byte changes;

proctype PIni (mtype slef; mtype party; mtype nonce) { 	
	mtype g1;
	atomic { 
        IniRunning(slef,party);
        ca ! slef, nonce, slef, party; 
    }		
end1: atomic { 
        ca ? eval (slef), eval (nonce), g1, eval (slef);
        IniCommit(slef,party);
        cb ! slef, g1, party;
    }
}

proctype PRes (mtype slef; mtype nonce) {
    mtype g2, g3;
    atomic {
        ca ? eval(slef), g2, g3, eval(slef);
        ResRunning(g3, slef);
        ca ! slef, g2, nonce, g3;
    }

end3: atomic {
        cb ? eval(slef), eval(nonce), eval(slef);
        ResCommit(g3, slef);
    }
}

proctype PI () {
    bit kNa = 0;
    bit kNb = 0;

    bit k_Na_Nb__A = 0;
    bit k_Na_A__B  = 0;
    bit k_Nb__B    = 0;

    mtype x1 = None;
    mtype x2 = None;
    mtype x3 = None;

do
    :: ca ! B, gD, A, B
    :: ca ! B, gD, B, B
    :: ca ! B, gD, I, B
    :: ca ! B, A,  A, B
    :: ca ! B, A,  B, B
    :: ca ! B, A,  I, B
    :: ca ! B, B,  A, B
    :: ca ! B, B,  B, B
    :: ca ! B, B,  I, B
    :: ca ! B, I,  A, B
    :: ca ! B, I,  B, B
    :: ca ! B, I,  I, B

    :: ca ! (kNa -> A : R), Na, Na, A
    :: ca ! (((kNa && kNb) || k_Na_Nb__A) -> A : R), Na, Nb, A
    :: ca ! (kNa -> A : R), Na, gD, A
    :: ca ! (kNa -> A : R), Na, A, A
    :: ca ! (kNa -> A : R), Na, B, A
    :: ca ! (kNa -> A : R), Na, I, A
    :: ca ! ((kNa || k_Na_A__B) -> B : R), Na, A, B
    :: ca ! (kNa -> B : R), Na, B, B
    :: ca ! (kNa -> B : R), Na, I, B
    :: ca ! (kNb -> B : R), Nb, A, B
    :: ca ! (kNb -> B : R), Nb, B, B
    :: ca ! (kNb -> B : R), Nb, I, B
    :: cb ! ((k_Nb__B || kNb) -> B : R), Nb, B

    :: d_step {
        ca ? _, x1, x2, x3;
        if 
        :: (x3 == I) -> k(x1); k(x2)
        :: else k3(x1, x2, x3)
        fi;
        x1 = None;
        x2 = None;
        x3 = None;
    }

    :: d_step {
        cb ? _, x1, x2;
        if 
        :: (x2 == I) -> k(x1);
        :: else k2(x1, x2)
        fi;
        x1 = None;
        x2 = None;
    }
od;
}

init {
  atomic {
      if 
      :: run PIni(A, I, Na); 
      :: run PIni(A, B, Na);
      fi;

      run PRes(B, Nb);
      
      run PI();
  }
}

#define p	IniCommitAB
#define q	ResRunningAB

never  {    /* !([](([] !(p)) || (!(p) U (q)))) */
T0_init:
	do
	:: (! ((q)) && (p)) -> goto accept_S11
	:: atomic { (! ((q)) && (p)) -> assert(!(! ((q)) && (p))) }
	:: (! ((q))) -> goto T0_S14
	:: (! ((q)) && (p)) -> goto accept_S2
	:: (1) -> goto T0_init
	od;
accept_S11:
	do
	:: (! ((q))) -> goto accept_S11
	:: atomic { (! ((q)) && (p)) -> assert(!(! ((q)) && (p))) }
	od;
accept_S2:
	do
	:: atomic { ((p)) -> assert(!((p))) }
	:: (1) -> goto T0_S2
	od;
T0_S14:
	do
	:: (! ((q)) && (p)) -> goto accept_S11
	:: atomic { (! ((q)) && (p)) -> assert(!(! ((q)) && (p))) }
	:: (! ((q))) -> goto T0_S14
	:: (! ((q)) && (p)) -> goto accept_S2
	od;
T0_S2:
	do
	:: atomic { ((p)) -> assert(!((p))) }
	:: (1) -> goto T0_S2
	od;
accept_all:
	skip
} 