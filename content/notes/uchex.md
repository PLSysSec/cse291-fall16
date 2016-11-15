+++
author = "Gary Soeller"
date = "2016-11-07T01:37:21-07:02"
title = "uchex"
type = "notes"
draft = true

+++

Author: Gary Soeller

#### What problem does uchex address?

Static bug checkers require a full compiler front end(lexer and parser) to build
a complete grammar. This often requires an enormous engineering effort and is
not easy for developers to write their own static checker.

#### What is uchex?

uchex is a framework for easily writing language agnostic static bug checkers.

#### How does uchex solve the problem addressed?

uchex solves the problem by using a micro-grammar: a grammar which contains a
subset of the grammar being parsed. uchex allows developers to write a checker
for a subset of the grammar allowing them the ability to easily write a checker.
A major benefit of uchex checkers is that they are language agnostic.
Furthermore, micro-grammars can also be language agnostic since they only parse
a small fraction of grammars. This allows code to be reused easily.

#### What are the properties of a micro-grammar?

1. The original grammar is a subset of the micro-grammar.
2. The original grammar and micro-grammar have the same structure.

#### How does the uchex parser differ from a traditional parser?

1. Sliding window: This allows the parser to continue when it does not recognize
a token.
2. Wildcard: Allows the parser to match anything.
3. Commit points: Allows the parser to stop sliding forward once an important
token is reached for badly written micro-grammars.
4. Compositional parsers: Allows parsers to be chained together.

#### What is a belief-style checker?

A type of checker that makes assumptions about the code. While traversing the
code, if the checker can contradict an assumption, then there is an error.

All of the example checkers use belief-style, but they are not necessarily
required to.

#### What is the algorithm for the null pointer checker?

1. When a pointer is dereferenced, it is added to a "not null" set. The "not
null" set is the set of "beliefs".
2. Whenever a not null check is made, the pointer is looked up in the "not null"
set
3. If pointer is set, a belief is contradicted indicating that there is an
error.

The null pointer checker uses forward dataflow analysis. This allows the checker
to know information about the past. Other checkers use backward dataflow
analysis which gives the checker information about the future.

#### What type of bugs can uchex catch?

1. Intra-procedural. This is the most simple type of bug because it requires no
context outside of the function.

#### What types of bugs does uchex not catch?

1. Inter-procedural
2. Alias tracking

#### What type of grammar is uchex able to parse and why is this important?

uchex can parse LL(k) grammars. There are limitations with parsers so it is
important to know which type of parser is being used. One limitation of LL(k) is
that left-recursion can not be parsed. Therefore, the developer must eliminate
it from the grammar.

#### How is uchex evaluated?

uchex is evaluated against an unknown industrial static checker(called SystemX
in the paper). Both checkers are run on the same codebases and the results are
compared by counting the number and overlap of bugs found. It is important to
note that uchex and SystemX can use each others results as ground truth. This
way they can be used in conjunction to improve each other.

uchex is also evaluated to demonstrate simplicity and ease of developing new
checkers. The only metric used is lines of code. This does not say much so it
should be taken with a grain of salt.
