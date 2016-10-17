+++
author = "Matthew Chan"
date = "2016-09-23T01:37:21-07:04"
title = "Hails"
type = "notes"
draft = false
+++

Author: Matthew Chan

### What is the main contribution of the paper?

Aside from the artefact, the Model-*Policy*-View-Controller architecture, which
provides a framework for building IFC enabled web applications.

### What problem does MPVC solve?

Traditional web application structure (i.e. MVC) has security checks littered
across the code base, mostly in the controllers -- the situation does not
improve across different kinds of frameworks, both client and server side View
frameworks suffer from the same problem (e.g. user metadata sanitization in the
view).  Specifying policy this way has two major disadvantages (a) policies have
to be specified multiple times for the same piece of data, leading to (b)
forgotten checks, inconsistent policies, and difficulties with revising the policies.

MPVC allows for the centralised specification of security policies where they
logically belong (with the data) thus simplifying the view and controller by
making redundant checks in those components. This needs to be supported by a
runtime => Hails.

### What are principals? What are the three types of principals in Hails?

A principal is a participant in the system who is allowed to read and write
data. Policies are specified in terms of principals. Unforgeable tokens called
*privileges* represent the authority of principals at runtime.

- Users
- VCs and remote resources they communicate with
- MPs

### The Hails DSL allows policies to be specified via arbitrary actions. Does this affect the design of DCLabels?

It should not, since the labels evaluate to the same thing cf. policies
specified as pure functions, you still get a label in the DCLabels format. The
DSL affects only expressivity, and is safe with IFC controlled effects.

### How is the Hails labelled DB API different from the MP DSL? Does one get the same guarantees if she does not use the DSL?

> MPs may contain arbitrary code and can expose an arbitrary API

- Hails DB API: wraps the underlying DB API with labels, part of the Hails TCB.
- MP DSL: for describing MPs, which translate to calls to the DB API.

The DB API can be used to express things that maybe the DSL cannot. This is
purely a matter of convenience; things are safe as long as the Hails libraries
are used (policy is mandated by the Hails runtime anyways).


### How are things labelled in Hails?

See Fig. 2 on pg. 7

The Hails MP persistence model is based on a document-oriented model (similar to Mongo), where

- DB = { collection } (≈ tables)

  Every database has a label

- collection = { document } (≈ rows)

  Every collection in a database has a collection label

  MPs can specify coarse-grained DB and coll labels.

- document = { field } (≈ K-V mappings).

  Fields can be indexed *keys* identifying the document or non-indexed
  *elements*

  Documents and Fields can be labelled via a function of type `Doc -> Label`,
  i.e. label depends on document contents.


### Why does Hails need OS level confinement and how is this different from threads? Are there alternative designs for this mechanism?

- For running external programs, i.e. `splint` linter in the `gitstar` example
- Threads =/= Processes; a process can have many threads. Spawning threads in
  Hails/LIO is completely fine, the child thread acquires the label of its
  parent.
- This confinement does not extend to spawned processes, so we need a kernel
  level confinement solution. Hails uses standard Linux isolation mechanisms,
  but other sandbox/container solutions might also work, i.e. Docker.
- As discussed in class, a possible design might be to "flip" the process model and
  have all processes communicate via the safe Hails/LIO process. This way all IO
  is labelled and spawned processes can have access to the network and other
  resources. Sadly this doesn't work because of label creep. (explain the
  problem in detail?)

### How is Hails evaluated?

Same as Shill:

- **Expressiveness/usability:** built a few applications with Hails, including one
  by a team of undergraduate research interns who were novices in Haskell and
  Hails. Found that MP was hard to get right but extension with VC is easy.

- **Performance:** Evaluation against existing mainstream web frameworks, mostly
  demonstrating that interpreted languages (like Ruby) are terrible.
  + Performance is competitive cf. Java but...
  + DB performance is bad (mostly due to the Haskell Mongo library implementation,
    according to Deian)

- **Security:** this is the focal point. Tiny TCB in application code across all
  examples. How big is the TCB for the Hails library + runtime +
  LIO/DCLabels/COWL ecosystem?
  + The other parts are formalized in Coq :+1:

### Another policy enforcing framework is Jeeves/Jacqueline. How is Hails different?

- Jeeves is a language, whereas Hails is a library/EDSL. This makes Hails more
  flexible and easier to change from a language design point of view. (+ usual
  host-language features for free argument for EDSLs)
- LIO's programming model is more flexible (e.g., LIO has exceptions and threads).
- Jeeves is completely policy agnostic; Hails is *mostly* policy agnostic. The
  authors make a case for requiring policies be inspectable, i.e. to recover
  from failures (see concurrent LIO).
- Jeeves can specify policies on concrete data stored in DB directly, Hails
  requires a layer of indirection at the MP level. Unclear which is better.
- Hails has a story for confinement in the browser, via COWL, and for
  enforcement at the OS level.
- LIO addresses covert channels and generally has a stronger attacker model.
  Specifically, LIO supports termination sensitive noninterference (no leaks
  via termination channel). Jeeves supports termination insensitive
  noninterference (leaks via termination channel possible).
