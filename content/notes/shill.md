+++
author = "Deian Stefan"
date = "2016-09-23T01:37:21-07:01"
title = "Shill"
type = "notes"
draft = false

+++

#### What is the problem that Shill is trying to solve?

Writing more secure shell scripts. Especially when some of these scripts may
not be trustworthy.

#### Shill's goal is to follow the POLP. What is this?

Principle of least privilege: code should run only with the
privileges (authority) it needs to complete its task.

#### What is their driving motivation for POLP? What are their security requirements?

They wish to safely grade student assignments.

- can't corrupt server
- can't modify/leak test suite
- can't copy solution from another submission

#### Why do "commodity systems and their secure tools" not support the POLP?

1. It's difficult to even figure out what authority code needs. This is a
   policy problem: it's hard to specify policy today and it's hard for others
   to inspect the policy.
2. Enforcement mechanisms are not good enough (too coarse grained, too
   intrusive, not widely available).

#### How does Shill address these shortcomings?

1. Capabilities and contracts address policy specification and policy auditing.
2. Capabilities and contracts is used to enforce fine-grained policies at the
   language-level. MAC is used to extend the enforcement to arbitrary
   processes.

#### In addition to capabilities, shill has contracts. What is a contract? Why does Shill use contracts?

- Three kinds of contracts: function contracts, capability contracts, wallet contracts
- Shill uses them to impose restrictions on how code can use capabilities. This
  is not only for security, but also for flexibility: You really want to make
  it easy to compose code. This means not restricting your caller (be general
  in what you accept and specific in what you produce): would be inflexible
  programming model if code had to drop capabilities/privileges before calling
  function.  Instead: can be privileged, but when you execute code the contract
  restricts how capabilities are used. (Excuse the loose language.)

  See Fig 5 contract.  This is what they're referring to when talking about
  bounded parametric-polymorphism.

#### How does Shill enforce contracts on capabilities?

- Proxies: wrappers around capabilities that check contract before use.
- This is interesting, because you can imagine a more complex contract that
  allows for revocation.

#### In addition to enforcing contracts, the language-level implementation ensures capability-safety. What does this mean? How does this affect the language design?

Can only acquire caps:

- by introduction (from ambient script at script launch)
- as arguments (from user)
- deriving them from other capabilities

Affects the language design:
- can't serialize capabilities (why?)
- can't have mutable variables (why?)

#### What are ambient shill scrips? Why are they necessary?

- Used to create initial set of caps to give to capability-safe scripts.
- Without these capabilities most scripts would not be able to do anything
  useful. E.g., need to load libc.

#### What are capability wallets?

- p6: "mechanism to automate and simplify the discovery, packaging, and
  management of capabilities in a list"
- Useful in writing real-world code that loads libraries and needs global
  access to various parts of the filesystem, etc.

#### Do capability wallets reintroduce some of the ambient authority problem?

Unclear from paper. Seems like it would make it easy to load a non-trivial
number of caps, but then again it's more declarative than today's systems.
Seems like this is a functionality-security trade-off: abstracting away
capabilities is useful but may lead to cases where too many caps are left
around. Consider the case where libraries themselves change and may need
fewer privileges over time.

#### How does Shill extend its security to arbitrary processes?

Creating sessions and associating process session. Each session has privilege
map that record the privs that the session has for various kernel objects. 

- MAC labels attached to kernel objects.
- MAC labels are used to enforce capability privileges.

Could this have influenced the language design? :)

#### What is MAC? Why does Shill use this instead of extending the capability model to the OS?

Mandatory access control. Labels on objects are checked whenever object is
accessed. MAC doesn't require changing code to use capability-style programming.

#### Do shill scripts and capability-sandboxed processes have the same security guarantees?

No. Sandboxed processes are vulnerable to confused deputy attacks: clients can
use paths.  Moreover "capability model" is different: MAC enforcement checks
permissions when accessing objects, so any permission will do -- don't have to
use a capability.

#### What is the privilege amplification problem? How do they address this?

Having two differently-privileged capabilities to the same object and using one
instead of the other.

At the language level Shill doesn't have to worry about this since capabilities
cannot be combined. They actually implement an "object capability" model.

At the OS level: they simply don't allow multiple capabilities to the same object.

#### What is Shill's threat model? Does the system address this?

- Shill scripts and shill executables are not trusted.
- Sometimes the contract may be untrustworthy.

#### How did they evaluate Shill?

- Expressiveness: case studies (grading submission, package manager, apache, find & exec)
- Performance: some of the case studies, different implementation styles.
- Security: mostly coarse-grained vs. fine-grained. LOC for ambient scripts is interesting.

#### Is it expressive?

- Seems like it. At least they looked at different case studies.
- Polymorphic contracts are a huge plus.
- How sandbox is used for apache is unclear. Mostly unclear how shill scripts fit in.
- How would you evaluate this more methodically?

#### Where is most of the overhead?

- Contract checking.
- Startup cost and creating sandboxes is also not cheap.
- How can these be optimized?

#### Are Shill scripts more secure than your bash scripts?

- Definitely!
- The ambient scripts are not tiny. Would've been interesting to see if anybody
  messed up writing these or contracts and how that may change the design.
- Can we evaluate the security more methodically?
- What kind of security does Shill buy you?

#### Can we say anything about the implementation of the runtime itself?

Their implementation uses the `*at` family system calls (you should too!) which
have a capability-like programming model. See
[Capsicum](http://static.usenix.org/legacy/events/sec10/tech/full_papers/Watson.pdf)
paper for more details.

##### Why did they add linkat, flinkat, etc.? What is the TOCTOU vulnerability?

Since their enforcement is not at the OS level they need the capability model
to ensure that the filesystem doesn't change from under them.

Suppose you want to open `/a/b/c` for writing; the system would resolve
`/a/b/c` and check if you have access to this. Let's say OKAY. Before it gets
back to you, another process may have removed `c` and created a link `c` to
something you don't have access to.

See the [Traps and
Pitffals](http://www.isoc.org/isoc/conferences/ndss/03/proceedings/papers/11.pdf)
paper for more details.
