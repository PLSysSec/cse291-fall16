+++
author = "Deian Stefan"
date = "2016-09-23T01:37:21-07:00"
title = "Confused deputy"
type = "notes"
draft = false

+++

#### What is the scenario that the paper is describing?

`(SYSX)FORT` is a fortran compiler, that:

1. Needs to write stats to (SYSX)STAT
2. Allows user to provide filename where debugging output is written to at run
   time.

In order to do (1) the compiler is given the _home files license_. This allows
the compiler to write files in its home directory.

#### To protect files the system was using access control lists. Whare are ACLs?

- Lists associated with objects (files) that specify the subjects that are
  allowed to access the objects (and how).
- Processes run on behalf of subjects. When accessing object system checks
  if the object ACL permits the subject to access it.

#### What's the concrete problem they ran into?

Billing info is stored in the home directory. So user can provide billing
filename to compiler and trash the directory with debugging info.

#### What's the underlying problem?

- Authority to write to stats file was used to writte debugging output.
- If, instead, the ivoking user's authority was used to write the debugging
  output instead, there would be no problem.

This is called the confused deputy problem. The fortran compiler was confused
into using the authority for one purpose towards another goal.

#### Can't we just set the right ACLs?

- No, this get super complicated. It sometimes breaks secure programs (too
  restricting). Other times it's insecure (not restricting enough).
- They had to write requirements as long boolean formulae.

#### What is the switching hat idea? Why didn't it work?

- Syscall that allowed switching mode from one authority to another.
- Didn't generalize beyond file system or two authorities.

Is this fundamental or mode a limitation of their exploration? Can you think of
a way of making the "swtching hats" idea work if you can modify the programming
language and have more than 1 single syscall change at your disposal.

#### What are capabilities and how do they solve this problem?

- A capability tells you which file to access and gives you the authority to do
  so. It removes the disconnect between naming and authority.

- With capabilities:
  - The system gives the compiler the capability to the stats file.
  - When invoking the compiler, the user must give the compiler the capabililty
    to the debugging file. If the user has this capablity, we know that they
    can write to the file. So the compiler can write to it too. Importantly, it
    cannot be confused into writing to the billing file since it doesn't have
    the capablity (name+authority) to this file. Something must grant it this
    capability.

#### Capabilities can help the with _Trojan horses_ problem; what is this? And how do capabilties help?

- Call program to do one thing and it does something else.
- Capabilities help by limiting what the program can do. Only give program
  least authority it needs. Consequence: "principle of least surprise".


#### Capabilities can help the with the _mutually suspicious users problem_; what is this? And how do capabilities help?

- Common scenario: Alice has sensitive data (taxes) and wisher to run Bob's
  accounting program. Bob doesn't want to share his super secret algorithm.
- Can run program with no capabilities other than the ones you grant it. This
  ensures that if you don't give it capability to talk to network, it can't do
  so.

We'll see how information flow control helps address this problem and what the
different trade offs are.
