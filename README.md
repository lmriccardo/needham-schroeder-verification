# Needham-Scrhoeder Protocol Verification

This is the repository for the project of Formal Methods In Software Development course at La Sapienza. This project is based on the paper [Using SPIN to Verify Security Properties of Cryptographic Protocols](http://spinroot.com/spin/Workshops/ws02/maggi.pdf). 

## Introduction

The **Needham-Schroeder Protocol** is a well known authentication protocol that aims to provide a mutual secure authentication in order to provide a secure communication channel between two main roles: *initiator* A and a *responder* B. Once authenticated, A and B, can start exchanging messages. The Needham-Schroeder protocol is based on the PKE (Public Key Cryptography) where each agent H has: a public key PK (knows by anyone) and a secrect key SK (knows only by the owner). This is the general Needham-Schroeder Authentication Protocol

<img src="https://i.imgur.com/bCocgkt.png" alt="Complete Needham-Schroeder Protocol" align="center">

If we assume that A and B already knows each others public keys, we can remove four of the seven steps, i.e., those involving the trusted entity, obtaining the following reduced model

<img src="https://i.imgur.com/JfZo95i.png" alt="Reduced Needham-Schroeder Protocol" align="center">

---

## Verification

The model has been verified with [SPIN](https://spinroot.com/spin/whatispin.html), [Murphi](http://formalverification.cs.utah.edu/Murphi/) and [NuSMV](https://nusmv.fbk.eu/), three well known model-checkers. 

>Say that X takes part in a protocol run with Y if X has initiated a protocol session with Y. Say that X commits to a session with Y if X has correctly concluded a protocol session with Y. 

Following the above definition, we can state that: the *authentication* of B to A means that A commits to a session with B and B has indeed taken part in a protocol run with A, and viceversa. These are the two properties that we want to verify. In LTL we have

```
[] (([] !(IniCommitAB)) || (!(IniCommitAB) U (ResRunningAB))) --- P1
[] (([] !(ResCommitAB)) || (!(ResCommitAB) U (IniRunningAB))) --- P2
```

Finally, I added one more property to be verified: the **deadlock** property. In this model we have a deadlock only if we cannot never reach the authentication, i.e., if the protocol is stuck and no authentication has been reached. This is the corresponding LTL spec

```
[] <> (  IniCommitAB & IniRunningAB
       & ResCommitAB & ResRunningAB) --- P3
```

These are the results of the verification step

<img src="https://i.imgur.com/z1GT5r4.png" alt="Verification Results" align="center">
