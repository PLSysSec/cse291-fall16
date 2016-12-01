+++
author = "Abdulrahman Alkhelaifi"
date = "2016-11-22T01:37:21-07:02"
title = "SecVerilog"
type = "notes"
draft = false

+++

Author: Abdulrahman Alkhelaifi

#### Why do the authors want to implement IFC at the hardware level?

- Hardware can be leveraged to create additional information flows that violate
  a security policy such as timing channels if one only enforces this policy in
  software.

- IFC allows sharing resources as opposed to separating the hardware resources
  into completely different levels/partitions which adds overhead and complexity.

#### What is the goal of SecVerilog?

- Enforce fine-grained information flow control for hardware designs in a
  statically verifiable fashion.

#### How does SecVerilog achieve that goal?

- Variables (registers and wires) are labeled (e.g. low and high) such that the
  labels specify a security lattice. The type system statically verifies that the
  information flow does not violate the security policy defined by the labels.

#### What is their attacker model? What attacks they do not consider?

- The authors consider a software level adversary who can observe all public
  information labeled low (storage channel) as well as measure the timing of
  hardware operations (timing channel).

- The authors do not consider physical attacks such as differential power analysis.

#### Is this a valid attacker model?

- The authors mention power consumption analysis as physical attack, however,
  it is possible to learn information about power consumption through software
  on many real systems (e.g., battery information).

#### What is a cache probing attack?

- The cache is shared between processes and hence one process can affect the
  timing of another process' memory access operations in an observable way that
  can be measured and potentially leak secret information.

#### Why are timing channels difficult to control?

- Timing channels are difficult because secret information can affect timing in
  many ways. For example, in software, a loop or an if statement with a secret
  condition; in hardware, a shared cache as explained in the previous question.

#### How do the author solve timing channels?

- They separate shared hardware resources (such as cache) into multiple
  partitions corresponding to multiple security levels (such as high and low)

- The hardware design follows a set of restrictions that prevent information in
  the high partition (secret) from affecting the outcome or timing of information
  in the low partition (public).

- They introduce labels for the Verilog HDL that define information flow policies
  and enforce them at statically.

#### Why is `if (h1)` (labeled L) not considered a timing channel even though h1 is in the H partition?

- Because the timing of the if statement is determined by the existence of h1
  and not the value of h1 hence no secret information can be learned by
  measuring the execution time.

#### What are dynamic labels and why are they needed?

- Dynamic labels are labels that can change at run time and are expressed as
  functions of some input.

- They allow for sharing hardware resources between multiple security levels.
  For example, a register can have a dynamic label if during run time it can
  store both a low and a high value.

- Importantly, there are no static checks to ensure IFC safety even if
  registers can take on different labels at run time. The static system ensure
  that IFC cannot be violated.

#### What are dependent types?

- They are types whose definition depend on some value. The authors define labels
  with type that can be H or L depending on some value.

#### What is implicit declassification? How do they solve it?

- Implicit declassification happens when a secret value is copied into a
  variable with a dynamic label that can change label from high to low at
  run time and potentially leak the secret value.

- They insert code that dynamically deletes the content of the register if
  implicit declassification is detected during the static analysis.

#### What are label channels?

- Label channels exist when the labels change dynamically and can consequently
  encode and leak information.

#### Describe two approaches to mitigate label channels and their shortcomings?

- No-sensitive upgrade: forbids raising a label in a high context. Rejects safe
  code where a variable can safely raise its label in a high context if the
  variable starts with a low label before the context.

- Flow-sensitive: raises the label of a variable to the context label. Rejects
  code where a label raise can cause a flow violation in a later code that
  was caused by the raised label.

#### How do the authors solve label channels?

- They modify the above two to check the label of a variable at the merge
  point of a branch and verify that the new label is at least as high as the
  context label.

#### How do the authors evaluate SecVerilog?

- They implement and verify a MIPS processor using SecVerilog and compare its
  overhead against an unverified MIPS implemented with Verilog. They find that
  the overhead in terms of delay, area, and power to be very small.

- They compare the performance of their secure MIPS against a regular MIPS
  which shows significant overhead.

#### Why is their MIPS processor slower than a regular MIPS process?

- Their implementation includes timing channel protections added to the cache
  and the pipeline.

- They partition the cache into high and low. When the timing label is high,
  both high and low partitions can be accessed. However, when the timing
  label is low, a cache access to the high always returns a miss. This clearly
  adds overhead to the cache.

- For the pipeline, they flush it whenever there is a change in the timing label
  in order to disallow a high instruction from stalling a low instruction
  which can leak information. This is also a clear performance overhead.
