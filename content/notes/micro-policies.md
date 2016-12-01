+++
author = "Hannah Chou"
date = "2016-11-29T01:37:21-07:02"
title = "Micro-policies"
type = "notes"
draft = false

+++

Author: Hannah Chou

# What are the high-level contributions of this paper?

A methodology to formally verify security of various security reference
monitors atop tagged hardware.

# What is a reference monitor?

Code/hardware that mediates all operations according to a security policy. The
monitor should generally be small (easy to audit, since this is the TCB),
self-protecting and correct.

# What are downsides to implementing a reference monitor in software?

Performance and security.

# What are the 3 machine classes that the authors present as part of their methodology?

Abstract machine, symbolic machine, concrete machine.

# Why do the authors split it up into 3 parts? How is it useful?

The abstraction level helps with reasoning about security policies at a high
level irrespective of the implementation. The symbolic layer specifies the
micro-policies in terms of symbolic tags. FInally, the concrete is the
implementation that reflects the hardware. All layers are written in Coq,
allowing proofs of security policies.

# What is the purpose of backward refinement?

To prove that any program that is safe (and thus takes a step) in a low-level
machine can take a step in the high-level machine. When a program is about to
violate security, it gets stuck.

# Why can't/don't they use forward refinement?

Forward refinement would require that the abstract levels account for details
in the lower, more concrete level. That would defeat the purpose of having
abstract levels that hide details of implementation.

# What is the abstract machine?

The basic RISC machine with added instruction primitives and pre-conditions
specific to a security policy (e.g. mkkey, seal, and unseal for the Sealing
Machine example).

# What is a monitor service?

A monitor service is the added instruction primitives that are implemented as a
rule in the symbolic machine.

# What are the assumptions they make with the monitor services?

That the service code is good and safe as provided by the micro-policy
designer. The encoding has to be correct to some degree, but their backwards
refinement proof also help ensure that a bad implementation can't be proved
correct.

# Why do they use a rule cache in the concrete machine?

To improve performance.

# What is the job of the miss-handler?

The miss handler retrieves rules if they are missed in the rule cache and
compares the rules to the attempted instruction. Because of this mixed hardware
software approach, they can't actually address covert channel information
leakage attacks (that you may care about in an IFC system).

# What are the four types of tags?

Memory, registers, PC, and services. 

# Do micro-policies associate with memory contents or with memory locations? Would this matter for implementation for concrete machines?

They could be associated with both. Yes, it just means it is implemented
differently in concrete machines, but it is the same syntax in the symbolic
machine.

# Why do they need monitor self-protection? How do they implement monitor self-protection?

The monitor code/data lives in ordinary memory. Monitor code/data is tagged
with a monitor tag so that untrusted code cannot access it. DS: Your memory
better have ECC, otherwise this is prone to the rowhammer.
