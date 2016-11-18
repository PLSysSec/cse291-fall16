+++
author = "Fucheng Gao"
date = "2016-11-17T01:37:21-07:02"
title = "Ironclad Apps"
type = "notes"
draft = false

+++

Author: Fucheng Gao

#### Where was this published?

OSDI, top systems venue

#### What kind of need is satisfied by Ironclad?

People want to assure their data secure when running apps in the could, without
trusting the cloud provider.

#### What's the shortcoming of previous work on verification?

Currently software verification can provide strong guarantees, but the cost is
often high -- e.g., seL4 took over 20-person years.

#### System features

- It can completely verify the software stack, which means it assume every part
  of software is untrusted, e.g. OS, BIOS, etc.
- The verification is on low-level assembly, meaning some of the toolsets
  (e.g., DafnyCC) need not not trusted.

#### Goals

1. Remote equivalence: A remote user should receive the same sequence
   of messages as a user communicating with the app abstract state machine.
2. Secure channel: Remote user can establish a secure channel to the app, in
   the presence of an untrusted OS.
3. Completeness: Every software component must be verified.
4. Low level verification: verify the actual instruction to that are executed.
5. Rapid development by systems programmers: Non-expert developers should be
   able to rapidly develop a verified Ironclad app.

#### Non-goals

- Compatibility
- Performance
- Covert-channels

#### Main techniques used by Ironclad

1. Late launch: Run application in a protected environment
2. Trusted computing: Tight software to a encryption key
3. Software verification: Prove software action follows specification

#### Threat model

Provide security against software-based attackers, who may run arbitrary
software on machine before executing or after app executes. The adversary may
attack the BIOS, OS, etc.

Ironclad only provides privacy and integrity; no liveness/DOS or consideration
for covert-channel attacks.

#### What is the TPM (Trusted Platform Module) and how is it used by Ironclad?

The TPM offers facilities for the secure generation of cryptographic keys,
random number generation, signing with the platform key, etc.

The TPM is used by Ironclad to prove to the remote user that the app they think
is running is indeed that; i.e., the TPM is use for attestation. See
(TXT)[https://en.wikipedia.org/wiki/Trusted_Execution_Technology] for modern usages.

#### Developer workflow

Firsts, the developer write the high-level specification (trusted) and then
implements the app in Dafny (untrusted), using Hoare logic pre and post
conditions to make aid the verification. Using a specification translator, the
high-level spec will be translate to a BoogieX86 specification. The DafnyCC
complier will also compile the implementation into BoogieX86.  The verifier
will then verify if assembly code "matches" the spec. Finally, the trusted
assembler and linker produces the final binary.

#### What kind of specification types does Ironclad rely on?

- Hardware specifications
- App Specifications

#### How does Ironclad simplify hardware specifications? 

It only defines spec for the introductions it can reason about and uses in the
compilation stages; this is only slightly less than 60 instructions.

#### How does Ironclad reduce app verification cost?

- Preliminary verification: It performs a basic verification on Dafny code via
  Z3. This lets developers quickly detect bugs when programming.
- Modular verification
- Shared verification

#### Besides functional correctness what else does Ironclad prove?

They ensure privacy by proving noninterference. This is proved via Boogie's
SymDiff.

#### Why is noninterference not usually practical for real apps? 

Apps need to leak data. To this end, Ironclad introduced declassification via a
state machine. 

#### How was remote equivalence proved?

In short: they prove functional correctness for the declsssifier and noninterference for
the program up to the declassify statement and after it.

#### What feature does DafnyCC provide? 

- Type safety
- Array bound safety
- Transitive stack safety
- High-level property preservation

#### What is late-launch?

It resets the CPU to a known state, stores a measurement (hash) of the
in-memory code pointed to by the instruction’s argument, and jumps to that
code. After a late-launch, the hardware provides the program control of the CPU
and 64 KiB of protected memory.
