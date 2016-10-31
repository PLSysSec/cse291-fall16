+++
author = "Deian Stefan"
date = "2016-09-28T15:44:04-07:08"
title = "COWL questions"
type = "assignments"
draft = false

+++

1. Why are labeled blobs crucial for making COWL practical? (Can't a context
   just raise its label to ensure that a receiving context is at least as
   sensitive before sending it data? Come up with a scenario where this
   wouldn't work.)

2. Why does COWL not allow arbitrary JavaScript objects to be labeled and sent
   via `postMessage`? (I.e., why must objects be _structurally clonable_?)

3. One can think of COWL as an adaptation of LIO for the browser. But, unlike
   for LIO, we cannot prove termination-sensitive non-interference (TSNI) for
   COWL. Recall what TSNI is and explain why we can't prove this COWL.
