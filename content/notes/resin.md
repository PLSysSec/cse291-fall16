+++
author = "Caroline Kim"
date = "2016-09-23T01:37:21-07:03"
title = "Resin"
type = "notes"
draft = false
+++

Author: Caroline Kim 

#### What challenge does Resin aim to address?

Resin is a language runtime that equips programmers with the ability to encode and enforce data flow assertions. Resin provides data flow tracking while requiring few changes to the existing code.

#### Which security vulnerabilities would Resin catch and which would it not?

Main use case is protecting against web application vulnerabilities such as SQLi/XSS. It is assumed that both the entire language runtime and the application code itself is trustworthy -- Resin does not protect against bugs in this code.

Resin does not catch implicit data flows such as those resulting from conditional branch and ordering of data.  Hence, the attacker model assumes that the application code itself is also trustworthy.

#### How does Resin enforce assertions?

Through filter objects and policy objects. Policy objects are defined for data and filter objects are defined for channels. Assertions for data can be specified in policy objects through `export_check` which will be called by filter objects.

By having this separation, developers can revise policy objects without having to worry about all the filter objects.

#### What are default filter objects?

By default, Resin creates filter objects at the "edge of the runtime." This encompasses all the runtime I/O, including sockets, HTTP layer, SQL layer, and other code imports. Less work for developers!

#### How does Resin handle data tracking?

Data objects are tagged with policy objects at the primitive-level (integer, character in a string, and files).

#### How do several assertions co-exist for a file?

Multiple policy objects can be attached to a file as part of a policy set.  Policy objects are attached to data in a fine-grained manner via a merge. When a merge is needed Resin, by default, takes the union of policy objects. But this merge policy can be overridden.

#### Why does Resin serialize policy objects?

For persistently stored data, Resin serializes policy objects so they don't have to be saved manually.

Importantly, only class names and field values are serialized; this allows policy object code to change without having to rewrite serialized policies.

#### How do the authors evaluate Resin?

- Security: Lines of code (how easy is it for developers), preventing vulnerability (100%?), whether it works properly on edge cases
- Performance: Overhead is 33%, overall. Higher when policy is present and a lot higher for those involving SQL operations (parsing the query is required)
