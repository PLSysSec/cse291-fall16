+++
author = "Brian Johannesmeyer"
date = "2016-11-14T01:37:21-07:02"
title = "S2E"
type = "notes"
draft = false

+++

Author: Brian Johannesmeyer

#### What conference was this paper in?

- ASPLOS 2011, where it won best paper

#### What types of analyses can a developer do on their code?

1. Understand observed behavior
2. Characterize future behavior
  - Should be able to do "what-if" analyses
  - However this is difficult because systems are large and complex

#### What three properties does their platform offer?

1. Efficiently analyze *entire families of execution paths*
  - i.e. More than one path of execution, and show that properties hold for all
    paths in a system
2. Maximize *realism* by running the analyses in a real software stack
  - Take into account the whole environment surrounding a program
  - Most approaches abstract away the environment behind a model, but that may
    lose accuracy, and is also labor-intensive
3. Ability to *directly analyze binaries*
  - Access to source code is rarely feasible
  - However, is this really a feature? Or are they *constrained* to binaries?
    This may not work on, e.g. direct JavaScript analysis.

#### What is symbolic execution?

- Program analysis to determine what inputs cause each part of a program to execute
- Treat program as superposition of possible execution paths
  - e.g. `if(x>0) ... then ... else` treated as superposition of two possible
    paths: one for x>0 and one for x<=0.
- For some constraint (e.g. x>0), instead of allowing a variable to take on a
  concrete value (e.g. x=5), it takes on a whole set of values (e.g. x:(0,+∞))

#### What insight makes S2E different from normal symbolic execution?

  - Often only some families of paths are of interest to developers (e.g. might
    not care about analyzing kernel code)
  - S2E can selectively choose what to symbolically execute by going back and
    forth between multi-path mode (i.e. with symbolic values) and single-path
    mode (i.e. with concrete values)
  - Also, things can be thrown away in the analysis if we don't care about it

#### How are symbolic values converted to concrete values?

- By simply choosing a value from the symbolic set

#### How are concrete values converted to symbolic values?

The symbolic value is constrained to whatever the concrete value was (e.g. x=5,
when originally x>0) to take into account any side effects x=4 may have had.
What can go wrong here? 
- You lose a lot of information about the value later on when you convert back
  to a symbolic value, i.e. may overconstrain a value
- It affects completeness

#### What is overconstraining?

- Constraining a value (whether by soft or hard constraints) so much that it
  cannot go down future paths
- What is a soft constraint?
  - Constraint imposed by symbolic/concrete boundary (e.g. x:(0,+∞) -> x=5)
- What is a hard constraint?
  - Constraint imposed by code (e.g. x>0 in `if(x>0)...then...else`)
    
#### How is the process of converting from symbolic to concrete values and back processed?

- According to an execution consistency model

#### Let’s define the parts of an execution consistency model…
- Analysis spaces
  - **System**: complete software system under analysis, including programs,
    libraries, OS, etc.
  - **Unit**: the part of the system to be analyzed
  - **Environment**: the part of the system that’s not analyzed
- Path types (look at figure on top right of page 4)
  - **Statically feasible**: there exists a possible path in the system 
  - **Locally feasible**: there exists a possible path in the system that’s
    consistent with data-related constraints in the unit
  - **Globally feasible**: there exists a possible path in the system that’s
    consistent with all data-related constraints (i.e. in both the unit and the
    environment)
- Metrics
  - **Complete**: every path through the unit that’s globally feasible will
    eventually be discovered by exploration done on that unit
    - i.e. all execution paths can be discovered
  - **Consistent**: every path through the unit has a corresponding globally
    feasible path through the system
    - i.e. the unit can correctly run on the system
- Why do we care about completeness and consistency?
    - We can do different things with their tradeoffs (see table 1)

#### Strict consistency

- Based on globally feasibility
  - Admits only globally feasible paths, i.e. only allows paths that are
    consistent with ALL data-related constraints
- What is *Strictly Consistent Concrete Execution (SC-CE)*?
  - System is a black box
  - Only a single execution path; executed non-symbolically
  - Used for:
    - Units tests, fuzzing
    - Valgrind
    - Anything that executes along a single path, generated by user-specified
      concrete inputs
  - Implementation
    - Doesn't symbolically track anything
- What is *Strictly Consistent Unit-level Execution (SC-UE)*?
  - Environment treated as a black box
  - Exploration engine allowed to gather and use information internal to the unit
  - Used by: symbolic and concolic execution tools
  - Implementation
    - Symbolic value turned into concrete value when units calls environment
    - When environment returns back to unit, the soft constraint it created
      becomes a hard constraint
    - This hinders completeness
- What is *Strictly Consistent System-level Execution (SC-SE)*?
  - Nothing is a black box
  - Exploration engine allowed to gather and use information about the entire
    system
  - Limited by: path explosion problem
  - Implementation
    - Symbolic values everywhere
    - Path explosion
      - Can use heuristics to prioritize path exploration,
      - Or employ incremental symbolic execution
        
#### Local Consistency (LC)

- Avoids exploring all paths in the environment
- Replaces results of calls to the environment with the symbolic values that
  represent possible valid results
  - e.g. `write(fd, buf,count)` can return any integer between -1 and count
- Allows for inconsistencies in the environment while keeping the state of the
  unit internally consistent
- No false positives because the internal state is consistent
- Implementation
  - At environment-boundary, concrete output value is turned into a symbolic
    value based on the function’s specification
  - However, if symbolic data is written to the environment, it may become
    inconsistent
    - If a branch in the environment depends on symbolic data, the execution
      path must be aborted
      
#### Relaxed consistency

- Disadvantages
  - Inconsistent in the general case
  - Internal state of the unit may be inconsistent, producing false positives
- Advantage: Performance
- What is *Overapproximate Consistency (RC-OC)*?
  - Path exploration can follow paths through the unit while completely
    ignoring the constraints 
  - E.g. call to write() would not bound the return value
    - Thus, violates the specification of the write system call
  - Used for: reverse engineering
    - Why is it used for reverse engineering?
    - See 6.1.2 - They fake the hardware in order to understand what the
      drivers are doing
  - Implementation
    - At unit/environment boundaries, converts concrete values into
      unconstrained symbolic values
    - E.g. All possible values that write() could return, rather values it
      should return
    - Gives completeness at the expense of consistency
- What is *CFG Consistency (RC-CC)*?
  - Exploration engine allowed to change any part of the system state as long
    as the explored paths correspond to paths in the unit’s inter-procedural
    CFG
  - Used for: disassembling obfuscated and/or encrypted code
  - Implementation
    - Pursues all outcomes of every branch, regardless of path constraints
    - Thus, follows all edges in the unit's inter-procedural CFG

#### S2E API

- Tables 2 and 3 give the best overview of what core events can be used to
develop analysis tools, and an idea of the interface to the *ExecState* object.
  
#### Implementation
- How are bugs that may result from slower system execution in symbolic mode
  mitigated?
  - The virtual clock is slowed down when symbolically executing a state
- Definitions
  - **Virtualization**: creating a software-based (or virtual) representation
    of something rather than a physical one
  - **Dynamic binary translation**: 
    - Emulation of one instruction set by another through translation of binary
      code (e.g. ARM -> x86)
    - S2E turns blocks of guest code into corresponding host code
    - Dynamic means it happens as it executes
      - Translates code as it is explored
      - Typically one basic block is translated at a time then cached
  - **Copy-on-write**: improves performance by only copying an object when the
    copy or the original is written to

#### Evaluation

- What 3 questions did they try to answer and how did they go about evaluating them?
  1. Is S2E a *general* platform for building tools?
    - Showed that S2E can be used to build 3 very different tools (section 6.1).
  2. Does S2E have reasonable *performance*?
    - Discussed its overhead in both concrete mode (~6x) and symbolic mode
      (~78x) and ways to reduce it (section 6.2).
  3. What are the *tradeoffs* between choosing different execution consistency
     models?
    - Gave figures showing code coverage, memory usage, and constraint solving
      time based on which consistency model was used (section 6.3).
- What is Table 4 trying to convey? Do it do so successfully?
  - It is trying to convey the usability of S2E: that it is straightforward to
    instrument and create custom analysis tools. However there are a few things
    that are wrong with their approach:
    - First, they built DDT and RevNIC previously, so they already understand
      the ins and outs of developing these types of analysis tools. Thus, their
      development time should naturally be dramatically shorter because they've
      already implemented a similar system. This confounds their development
      time results.
    - In addition, not many details are given for their calculation of
      "person-hours".
    - Also, it mentions in Table 4's caption that "10 KLOC of offline analysis
      code is reused in [REV+]". However, that element of the table does not
      have those 10 KLOC added to it. If those 10 KLOC count against the
      previous implementation (i.e. 57,000 LOC), it should count against the
      new implementation too (i.e. 10,580 LOC instead of 580 LOC).
- Even after going through the tradeoffs of different consistency models in
  section 6.2, I don't think it would be immediately clear to developers which
  model they should use.