+++
author = "Sunjay Cauligi"
date = "2016-09-23T01:37:21-07:02"
title = "JIF"
type = "notes"
draft = false

+++

Author: Sunjay Cauligi 

#### What specific guarantees does JIF give? What don't they give?

No data leaks from within their framework, but no guarantees about certain
timing channels or other covert channels.

#### How does JIF compare to conventional IFC?

The main difference is the concept of multiple owners, each specifying their
own reader sets.

#### Slots and channels

Slots (variables) and channels cannot be relabeled; any data coming out of a
slot/channel takes on the label of that slot/channel.

This means that data written to a variable is relabeled with that variable's
label. (Why do it this way?)

#### Labels

The effective reader set of any labeled data is the intersection of all reader
sets in that label.

Declassification can only occur on a per-owner basis.

Access-control checks are done on writes, and so aren't necessary on reads.

#### Database of principal hierarchies

If there is a centralized database, is this system truly decentralized?

What challenges arise out of having this database?

What happens if the database is modified while code is executing?

#### Why does JIF still have some lightweight dynamic label checking?

It needs dynamic label checking for more complex external sources of data, such
as filesystem or database access, to ensure its non-leakage property.

#### How does JIF prevent implicit information leakage?

Blocks within if/while constructs are labeled according to their respective
branch conditions. Thus anything that happens inside one of these blocks is at
least as restricted as the knowledge of the branch condition.

#### How could JIF be improved to handle timing information leaks?

Open question.

#### Why is `if_acts_for` necessary?

JIF needs to check at run time whether the function has the correct authority
to act on the specified principal's behalf.

#### What might be a use case of having a record `r` with a more restrictive label than a field `r.f` in `r`?

Incidentally, what is the label of `r.f`? Is it <u>`f`</u>? <u>`r`</u> ⊔ <u>`f`</u>?

#### What is the use case for the `labelcase` construct?

When might one want to branch on a label's runtime value?

#### Why does `protected[T]` exist? What is it used for?

It's used to implement the lightweight dynamic label checking mentioned above.

#### What is the use case for the `get_label` function?

When might one want to examine the contained label inside a `protected[T]`?

#### Why does `get` expect a label to be passed in? What prevents one from simply passing in the label returned by `get_label`?

The label returned by `get_label` is itself guarded with the label <u>`p`</u>,
which is the original guard on the original contained label. Since both the
`success` and `v` return values from `get` are guarded by <u>`expect`</u>, only
someone with permissions for the original protected data can examine whether or
not they were able to successfully retrieve the value using `get`.

#### In what ways is a `protected[T]` similar to a capability model?

One can think of the `expect` parameter as a capability for retrieving a value from a `protected[T]`.
