+++
author = "Ariana Mirian"
date = "2016-09-23T01:37:21-07:08"
title = "Chrome extension system"
type = "notes"
draft = true

+++

Author: Ariana Mirian

#### Background

Presented in 2010, at NDSS (network and distributed system security).

The following people were on the paper:
- Adam Barth: (one of first people working on) Security at Chrome
- Adrienne Porter Felt: Usable Security at Chrome
- Prateek Saxena: Prof. at National University of Singapore
- Aaron Boodman: Helped build Chrome, now at Startup

They were all at some point invested in Google (or still are), and had a vested
interest in making a system that worked and was effective. 

To review, a browser extension is a third party software that extends the
functionality of a web browser. 

#### Problem

The question that the authors were trying to answer is if browser extensions
require such a high level of privilege.

In order to answer this, the authors analyzed Firefox Browser system and
implement an alternate extension system with the Chrome Extension System.

One could say that the Firefox model at the time was silly and had lacked any
regard for security. However, it is important to remember that extensions were
meant to supplement a user's experience and, before this point, the use case
for extensions wasn't clear. Firefox had no idea what to expect, while the
authors of this paper benefited from hindsight. 

The threat model is _benign but buggy_ extensions: a malicious attacker could
corrupt the extension and usurp its privileges.

#### Evolution of Firefox

The paper argues that the underlying issue of the four potential (out of many)
attacks is that Firefox extensions interact directly with untrusted content
while possessing a high level of privilege --- by rethinking the architecture
they aren't just fixing one problem, they are addressing most of them.

While they argue that there was no way to automate the extension analysis, there
might have been a way to perform a program analysis to look at how the APIs are
used. On this note, while their paper did well with only 25 extensions from the
Firefox Extension system, it could have benefited from a larger analysis to
provide a better picture of how the average extension dealt with privileges. 

Out of the 25 extensions that they analyzed, 19 had 'critical' privileges,
meaning that they could run arbitrary code on the user's system, while only 3
required critical privileges. This is an example of a privilege gap.

The paper then goes into discussing a security lattice that they used to
analyze the Firefox extension API. They show that there is a considerable
number of escalation points that need to be addressed, and that the separation
of privileges is not necessarily as easy as it seems. APIs need to be designed
from the start with privileges in mind.

From this analysis, they propose building a new system following the principle
of least privilege, privilege separation, and strong isolation.

#### Google Chrome Extension System

The Google chrome extension system implements privilege separation and isolation
mechanisms. 

##### Why did they need both? 

The privilege separation was broken into three differed hierarchies: _content
scripts_, _extension core_, and _native binary_.

Content scripts are JavaScript scripts that allow extensions to directly
interact with the untrusted web content (DOM) --- since they have the largest
attack surface, they do not have any direct access to privileged APIs. They can
only communicate with the extension core via message passing.

Extension cores have access to privileged APIs (which, for example, allow them
to create new tabs) as declared in the extension's manifest and approved by the
user at install time.  The core does not interact with untrusted web content
directly; it can only communicate with untrusted context via the content script
or using an XMLHTTPRequest.

Finally, the native binary can run arbitrary code or access arbitrary files.

The isolation mechanisms are similarly split up into separate parts.
- Origins are used to ensure isolation between different extension cores. This,
  for example, ensures that one extension cannot mess with another's
  `localStorage`.
- Extension cores and native binaries are run in different OS processes. This
  ensures isolation between themselves and content.
- Content scripts run in _isolated worlds_. They have a separate JavaScript
  heap and separate access to the DOM of the untrusted web page they run in.
  This ensures that content scripts are isolated from the untrusted content and
  other extensions (under the buggy but benign model).

#### Discussion

In order to evaluate their system, they measured page latency and DOM access
time --- both had increases, respectively 0.8ms and 33.3%. What was missing was
a lack of a user study to understand the implications of their system. In the
end, the hindsight from the Firefox extension system helped them a lot, because
they were able to see a (small) sample of how users use extensions and what
could go wrong. 

Today, the paper could be improved in various ways. You could look at more
extensions or determine more concretely what the APIs should look like, and,
given yet more hindsight, consider a more realistic attacker model.
