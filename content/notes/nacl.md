+++
author = "Shravan Narayan"
date = "2016-09-23T01:37:21-07:06"
title = "NaCl"
type = "notes"
draft = false
+++

Author: Shravan Narayan

#### What is the paper's high level goal?

To be able to run native binaries securely, while incurring as little overhead
as possible to ensure the safety of the system. 

#### What is the high level strategy?

This is done by ensuring that any faults or bug are isolated to the module, i.e.
the bug cannot be used to take over the entire system.

#### Why do you want native code?

Native code has the benefit of running on bare metal, i.e. there are no layers
of interpreters or virtual machines that are needed for them to operate. Thus
the performance of native code is significantly better than interpreted code of
virtual machine code.

#### What is the threat model?

The threat model is one of where a malicious website creator may use native
binaries to take over your computer, or a malicious entity could try to take
over the computer by abusing a bug in one of the native binaries that are
currently loaded on to the browser by a website. 

#### What are the inner and outer sandboxes?

NaCl implements its security by running native binaries on 2 layers of
sandboxes. The inner layer is a sandbox that implements fault isolation - i.e.
any bug in the program is isolated such that it cannot have an effect on the
rest on the system. The outer sandbox is an added safety mechanism - this is a
layer that restricts system calls to only a subset of allowed ones.  In the
Linux Chromium version, this is currently implemented via
[seccomp-bpf](https://en.wikipedia.org/wiki/Seccomp) which allow this sort of
system call filtering.

#### How is the software isolation enforced in the inner sandbox in NaCl?

Software isolation is enforced with the help of the x86 memory segmentation
features and an instruction verifier.  Segments ensure that the program cannot
read/write to parts of memory outside the untrusted code's bounds. The
instruction verifier ensures that only safe (e.g., no memory jumps),
properly-aligned instructions are allowed. Bit masks are used to ensure that
jump instructions cannot jump to the middle of existing instructions. 

#### What are some of the complications with parsing x86 code? What steps are taken to mitigate these complications?

x86 code has variable sized instructions. Even a particular instruction may
have representations in multiple lengths. This may be lead to non-aligned
overlapping instructions. Another challenge is self modifying code - which is
used in applications such as JIT code generation etc.

To reduce the complexity, all instructions are aligned at word boundaries (aka
32 bit aligned), self modifying code is not allowed and all jump instructions
are forced to jump to word boundaries.

#### What are examples of instructions or other operations not allowed by NaCl?

NaCl blocks any instructions that allow changing the segment state, system
calls, interrupts and return aka long jump instructions (a modified long jump
called NaCl jump which is an and instruction followed jump is allowed. The and
instruction ensures that the jump instruction stays at word boundaries.)

#### What happens if we don't mask jumps, i.e. what happens if we allow regular jump or return instructions instead of NaCl jump?

If we don't mask jumps, a program vulnerability could allow the execution of
instructions that are not allowed such as segment instructions, by creatively
jumping in the middle of an existing instruction. If the location for the jump
is picked carefully, the middle of a target instruction could be read by the
processor as an instruction which we want to block.

#### What happens if we don't use segmented memory?

Without segmented memory, there is nothing stopping a jump instruction to jump
to an arbitrary location outside the segment (e.g., to parts of the trusted
reference monitor). Thus we would need some other mechanism to enforce the
program memory isolation. One such technique is used in one of the papers
referred to in the NaCl paper - PittsField. The PittsField paper enforces this
isolation without segments by applying a bit mask on the most significant bits
before every jump to ensure the jump is confined to a part of the memory.

#### What are the various components included in a NaCl applications runtime?

Each sandboxed application is run in an environment with the following pieces 
- an inter module communications service: which allows communication between
  components, components and the browser via messages, shared memory segments
  and synchronization objects
- service runtime: which allows memory management APIs, thread creation interfaces etc.

#### Why does NaCl have SRPC and NPAPI?

SRPC is a protocol that allows communication between NaCl modules as well as
the JavaScript in the browser by declaring the procedural interface with basic
data types. NPAPI (Netscape Plugin API) is a protocol which is used to interact
with DOM, JS objects directly, etc. NPAPI is actually quite an old protocol
that is no longer used by NaCl. They have replaced this with a new protocol
called Pepper with the goal of better platform portability and security. 

#### How is the isolation provided by NaCl thwart a simple buffer overflow vulnerability that gives arbitrary code execution?

NaCl does not prevent the buffer overflow, however, the buffer is stored in a
separate data segment. So, a buffer overflow cannot be used to overwrite the
return pointer on the stack. Also, this segment is separated from the rest of
the call stack and the memory page containing the data segment is marked as
no-execute and so cannot be executed.  

#### What is the validator? What are the use cases and constraints?

The validator is a program that is used prior to loading a NaCl binary. This
program validates that a given NaCl binary confirms to all the rules about
using only allowed and word aligned instructions, masking jump locations, etc.
The validator thus needs to be able to efficiently parse x86 instructions - the
word alignment restriction as well as a small subset of allowed instructions
makes this simpler. As the validator is used just before loading the binary, it
is required that this operate with minimum overhead, so as to not introduce any
latency.

#### The paper talks about exceptions. What are they? How are they supported?

There are 2 types of exceptions:

- Hardware exceptions: interrupts delivered by the OS such as floating point exceptions
- Software exceptions: the regular exceptions encountered by the language which
  are handled by the try catch syntax.

Hardware exceptions are not supported and will cause the NaCl program to be
terminated. This is because segmented memory modes were not very well supported
by the OS - i.e. the OS doesn't have a mechanism to deliver exceptions to
processed which have modified the stack segment register.  Software exceptions
function as expected.

#### Are system calls allowed in NaCl? Describe the mechanism used to enable/block this?

System calls are not directly allowed. However NaCl provides a mediated
approach to some functions, including system calls, with the help of trampolines
and springboards. These mechanisms are implemented as part of the Service
Runtime. Trampolines are trusted code that removes the segment restrictions,
and calls into unsandboxed code. This code executes and returns via the
springboard. The springboard resets these stack restrictions. Note that the
springboard code is also used as to provide the threading interface for a NaCl
binary - however this cannot be invoked directly by the sanboxed NaCl app. 

#### The paper describes a particular memory layout for NaCl binaries? What are the benefits?

The memory layout starts with one page (4kb) of unallocated space - this is
used to detect null pointer exceptions as any reference to this memory will
cause a page fault. The next 60 KB is used by the service runtime to load the
trusted trampoline and springboard code. Trampolines can only contain function
whose entries are at word boundaries as they need to be callable by the NaCl
binary. The springboard should not be called directly by the NaCl binary as it
manipulates segment information and so have entries that are not word aligned. 

#### What were some of the modifications required to the compilers to generate NaCl binaries?

GCC was modified to ensure 

- function entries were only at word boundaries
- branch targets are 32 bit aligned
- to use nacljump for indirect transfers

#### What is the overhead of a NaCl binary?

Several benchmarks were run to estimate overhead - the average overhead seems
to be about 5%. Benchmarks included SPEC2000, graphics tests, video decoding,
physics simulations, and games. The equally important metric was the latency
overhead of the NaCl verifier, which was measured to be on the order of
30MB/second (small compared to download time).
