+++
author = "Atyansh Jaiswal"
date = "2016-11-29T01:37:22-07:02"
title = "miTLS"
type = "notes"
draft = false

+++

Author: Atyansh Jaiswal

##What is TLS?

TLS stands for "Transport Layer Security" and is the most used protocol for
secure communication. It's primarily used for communication over web in the
form of https. It's a direct successor of Secure Sockets Layer (SSL) and is
quite frequently called as SSL (TLS 1.0 was released as SSL 3.1).

## What does TLS do?

In general, TLS comprises of a handshake protocol and a record protocol. The
handshake protocol allows a server and client to authenticate each other via
some form of asymmetric encryption, while allowing the securely create a shared
shared key. The record protocol provides connection security for communication
between the server and the client, usually with some form of authenticated
encryption scheme. TLS provides a variety of cryptographic suites to facilitate
these protocols. The cryptographic suites range in strength with some old but
insecure algorithms still being supported for compatibility purpose.

## What's the paper about?

TLS has had a long history of security breaking bugs, usually to defects in the
implementation of the protocol. The miTLS paper presents a verified reference
implementation of TLS 1.2 written in F#. They create a modular implementation of
TLS and use PL abstractions (in particular refinement types and abstract types)
to prove soundness and security of their implementation of the protocol. They
also discuss some interesting attacks and how their implementation fixes them.

## What are the main goals of miTLS?

miTLS creates a reference implementation of TLS with the 2 main goals in mind-

1. Standard Compliance - Their implementation is compatible with the current TLS
RFC and can be used with various systems that use TLS. As such, their protocol
supports some ciphersuites such as RC4, which is known to be weak, but they mark
these as weak in their type system.

2. Verified Security - The security of the protocol is provably secure, i.e. the
privacy and integrity of data sent over TLS is preserved provided that strong
cryptographic ciphersuites were used to establish the handshake and connection
keys. They do this by designing classic indistinguishability and integrity games
using their typed primitives.

## Modular Implementation of miTLS

The implementation of miTLS is split into 45 different modules. Each module is
specified with an interface and an implementation. The interface declares the
types and functions exported by the module. The F7 typechecker verifies the
modules using these interface (using Z3 as an SMT solver to solve the logical
proofs). The modules are grouped into several major components, each with a
specific function. Interesting ones to note are the Record layer, which handles
the record protocol, and the upper layer, which consists of the handshake
protocol, alerts, and application data. 

There's a dispatch module that handles communication between these components
and the application, as such it handles message passing, fragmentation, etc.

## How do modules help provide security?

Proving security properties of each module separately allows for compositional
reasoning of security. In particular, the authors say that their main
contribution in this paper is that they can verify record layer security with
their Stateful Authenticate Encryption Module (StAE), Handshake layer security
with their Handshake Module (HS), and that the TLS protocol logic that deals
with application data, alerts, etc. securely implements the main API given
secure implementations of StAE and HS.

## What new attacks did they discover?

* The authors discuss an Alert Fragmentation attack where an attacker could
insert an alert fragment as part of the communication which is buffered, so
when the correct alert comes in, it's seen as a continuation of the previous
alert fragment, which breaks alert authentication. They fixed this by verifying
that alert buffer is empty at the completion of a handshake.

* Fingerprinting attack using compression - Not all ciphertexts provide security
against this. The amount that the plaintext can be compressed can reveal the
entropy of the plaintext which breaks the indistinguishability principle. They
fixed this by disabling TLS level compression in their implementation.

## Cryptographic Security by Typing

The authors use F7, which is a refinement typechecker for F#. They take of two
abstractions in type theory to prove security properties-

1. Refinements Types - These are types with predicates attached to them that can
be typechecked. As such, a type c:cert(Authorized(u,c)) specifies c to be of
type cert, such that c is an authorized cert for user u. This way, they can
encode the security properties of the primitives as part of the type system.

2. Abstract Types - Types can be declared as abstract which keeps the
representation of the type private, which ensures that any module will treat them
as opaque values, which provides secrecy and integrity.

## How they use typing rules

The main property of their type system is that a well-typed expression is always
safe (Theorem 1).

Theorem 2 provides the property that a program interacting with secrets kept
within 2 different modules cannot distinguish between the two.

They then define cryptographic games in their type system and show that the
security properties can be proven by the types alone rather than the
implementation. They represent weak cryptographic suites with not(Strong), which
allows the type checker to represent their weakness. They also define LEAK and
COERCE to represent key compromise and provide security guarantees against them.
