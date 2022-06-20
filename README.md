# Needham-Scrhoeder Protocol Verification

This is the repository for the project of Formal Methods In Software Development course at La Sapienza. This project is based on the paper [Using SPIN to Verify Security Properties of Cryptographic Protocols](http://spinroot.com/spin/Workshops/ws02/maggi.pdf). 

## Introduction

The **Needham-Schroeder Protocol** is a well known authentication protocol that aims to provide a mutual secure authentication in order to provide a secure communication channel between two main roles: *initiator* A and a *responder* B. Once authenticated, A and B, can start exchanging messages. The Needham-Schroeder protocol is based on the PKE (Public Key Cryptography) where each agent H has: a public key PK (knows by anyone) and a secrect key SK (knows only by the owner). This is the general Needham-Schroeder Authentication Protocol

<img src="https://i.imgur.com/bCocgkt.png" alt="Complete Needham-Schroeder Protocol" align="center">

If we assume that A and B already knows each others public keys, we can remove four of the seven steps, i.e., those involving the trusted entity, obtaining the following reduced model

<img src="https://i.imgur.com/JfZo95i.png" alt="Reduced Needham-Schroeder Protocol" align="center">

