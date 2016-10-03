+++
date = "2016-09-05T20:19:41-07:00"
description = "description"
draft = false
title = "Project ideas"

+++

Below is a list of project ideas. Some are more open ended or more
challenging than others. Hence, undertaking a substantial subset of
any of these is a reasonable goal for this class.

- Prototype a new extension system architecture (e.g., for Brave?)
  that has a stronger attacker model: malicious extensions.  (See
  [our position on browser extension
  design](https://cseweb.ucsd.edu/~dstefan/pubs/heule:2015:the-most.pdf)
  for motivation.) Studying how and what permissions existing
  extensions use today would be an interesting component to this.
- Explore the use of Service workers, obfuscation (in the crypto
  sense), and CSP to implement security monitors like COWL in existing
  browsers.
- Automatically rewrite and compartmentalize client-side web
  applications to leverage COWL.
- Implement a discretionary access control (DAC) monad that ties in
  with a database library and the filesystem to enforce Hails-like
  policies.
- Implement a Resin-like system for Node.js, using ES6 proxies and
  program rewriting to essentially implement taint tracking. (Credit:
  this idea came out of a discussion with Brad Karp who would be a
  natural collaborator.)
- Develop domain-specific symbol execution. Consider, for example, finding
  (security) bugs in web (e.g., rails or express) applications. Or, consider,
  for example, using symbolic execution to reverse-engineer custom hardware
  protocols -- come chat with me and Kirill Levchenko about this.
- Evaluate the Web Crypto API and design an alternative API that is
  less bug prone. Both  a simpler API and an API that uses IFC to
  ensure keys are not leaked are reasonable directions.
- Develop a formal model for least privilege. What does it mean for a
  program to be least privileged? Given this model, look at a real
  applications within some domain (e.g., browser extensions, mobile
  apps) and either show that they are least privileged or that they are
  not. Alternatively, apply the model to IFC, capabilities, or other
  mechanisms.
- Develop a Passe-like inference algorithm that uses tests to infer
  application security policies. Hypothesis: a type inference-like
  algorithm can be used to easily do this for ORM-based applications.
  Given enough access examples (traces) the policy become more
  general; but starts out very specific.
- Use program synthesis to generate Hails and Passe-like policies from
  user-supplied examples.
- Unify IFC, capabilities, MAC and DAC. Show how they are equivalent
  (e.g., an IFC-secure program can be enforced with capabilities and
  DAC). And show where the different mechanisms are not compatible
  (e.g., attacker models?). Working on an implementation or formal
  setting are both reasonable here.
- Extend LIO with software transactional memory (STM) without
  introducing covert channels. This is especially interesting if the
  transactional model can be extended to the filesystem.
- Model a real crypto-based protocol like FIDO or OpenID using a model
  checker (e.g.,
  [Murphi](http://formalverification.cs.utah.edu/Murphi/) or
  [Alloy](http://alloy.mit.edu/alloy/)).
- Explore the interaction of garbage collection and information flow
  control. Can we have an IFC system that won't leak via the GC?
- Explore the interaction of IFC and foreign function interfaces. Can
  we safely extend IFC systems with FFIs? (Maybe using Dune?)
- Design a new (graphical) language for describing secure systems
  (e.g.  dns servers, web servers, ssh servers) and generate the
  boilerplate security enforcement code to ensure security/isolation
  between different compartments (where untrusted code implements
  functionality).
- Implement Singularity-like SIPs, but using
  [Dune](http://dune.scs.stanford.edu/) to do it in hardware. It would
  be interesting to do this in the context of a new
  [Rust](https://www.rust-lang.org/en-US/) OS or
  [Servo](https://servo.org/).
- Design language/DSL that makes it easy to securely write
  applications that rely on crypto (e.g., encrypted email, encrypted
  chat).
- Implement a fast MPC language/DSL. E.g., by building on
  [λPS](https://cseweb.ucsd.edu/~dstefan/pubs/mitchell:2012:information.pdf)
  you can consider partially homomorphic encryption, network message
  batching, etc.
- Design language/DSL that makes it easy to have certain sensitive
  computations execute in an environment that is protected from the
  rest of the application/OS (e.g., by using SGX (enclaves) or
  offloading to SMC cloud).
- Design (monadic) DSL for expressing garbled circuits with the goal of
  proving security about arbitrary circuits (via composition) and
  generating efficient implementations (e.g., for x86 or FPGAs). This
  is joint work with Daniele Micciancio.
- Develop a formal model for browser binding code. This would make it
  possible to reason about security across languages like C++ and
  JavaScript. See [our position paper on binding-layer
  CVEs](https://cseweb.ucsd.edu/~dstefan/pubs/brown:2016:superhacks.pdf)
  for motivation.  Using
    [S5](http://blog.brownplt.org/2012/01/31/s5-wat.html) and maybe
    Rust (motivated by [Servo](https://servo.org/)) may be intersting.
- Implement
  [PAKE](https://en.wikipedia.org/wiki/Password-authenticated_key_agreement)
  in existing browsers (similar to
  [Stickler](https://www.henrycg.com/pubs/w2sp15stickler/). (Credit:
  David Mazières and Quinn Slack did this by modifying the browser
  several years ago. Shravan is working on something similar and reminded me of this idea.)
- Devise a policy language (maybe by extending Hails') to account for
  information leakage and an enforcement system for it. It would be interesting
  to tie this in with the external mitigation techniques we discussed in class
  or other equines like [differential privacy](https://en.wikipedia.org/wiki/Differential_privacy).
- Design a language that gives you similar capabilities as
  [BPF](https://en.wikipedia.org/wiki/Berkeley_Packet_Filter) but is amendable
  to analysis and query. For example, given a program written in this language
  you may wish to ask if the only thing it allows is TCP traffic on port 80. If
  this is interesting to you, come chat with me and Kirill Levchenko.
