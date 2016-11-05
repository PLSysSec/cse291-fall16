+++
author = "Ariana Mirian"
date = "2016-09-23T01:37:21-07:09"
title = "COW"
type = "notes"
draft = false
+++

Author: Rohit Jha


#### What is the motivation behind COWL?

* Flexibility vs privacy
* MAC-based confinement better than DAC


#### At a high-level, what does COWL do?

* COWL is a robust JavaScript confinement system for modern web browsers.
* COWL introduces label-based MAC to browsing contexts (pages, iframes, etc.)
  in a way that is fully backward-compatible with legacy web content
* Prevents information leaks


#### What are the design requirements for COWL?

* MAC with:

  * Symmetric confinement: two mutually distrusting scripts can each confine
    the other’s use of data they send one another

  * Hierarchical confinement: allows any developer to confine untrusted code,
    and confinement can be nested to arbitrary depths

  * Delegation: allows a developer explicitly to confer the privileges of one
    execution context on a separate execution context

## Background

#### What are some browser security policies and concepts explained in the paper?

* Browsing contexts
* Same-Origin Policy (SOP): how does SOP not prevent data from being disclosed
  to foreign origins?
* Content Security Policy (CSP): what are the limitations of CSP?
* postMessage and Cross-Origin Resource Sharing (CORS): what is the difference
  between these two?


#### What are the motivating web applications explained in the paper?

* Password strength checker:
  * What are the possible security risks here?
  * How does COWL add security to a third-party password checker?
* Encrypted document editor
* Third-party mashup
* Untrusted third-party library: How does COWL mitigate reuse risks?

## COWL Confinement System


#### COWL augments browsers with three primitives. What are these?

* Labeled browsing contexts
* Labeled communication
* Privileges


#### Structure of a label

*  (secrecy formula, integrity formula)
  * Secrecy: which origins can read a context’s data
  * Integrity: which origins can write it


#### How does COWL enforce label policies?

* Allowing a context to only communicate with other contexts or servers whose
  labels are at least as restricting


#### Can a script leak information through a newly created context? How?

* Newly created context implicitly inherits current label of parent
* The parent may specify a more restrictive label for its child


#### What are the two types of contexts COWL applications can create?

* Standard contexts: pages, iframes, workers, etc.
* Labeled contexts in the form of lightweight labeled workers (LWorkers)


#### What are LWorkers and why are they helpful? Why not use normal workers?

* Lightweight labeled workers which execute in the same thread as their parent
* Share the event loop with their parent
* Have access to COWL API, XHR constructor and can communicate with parent
* Parent can give read/write DOM access to child since they are in the same
  thread
* LWorkers simplify the isolation and confinement of scripts


#### How does COWL support labeled communication?

* Labeled Blob messages (intra-browser)
* Labeled XHR messages (browser-server)


#### What are labeled Blobs?

* Encapsulation of an inter-context message (payload - serializable and
  immutable Blob object) with the label
* This label is at least as restrictive as the sending context’s current label
* Receiving context can access label - and can access the message only after
  it’s label is raised as needed


#### Why are labeled Blobs useful?

* Sender can impose confinement on the receiver by labeling a message
* Receiver can delay reading the message content until they are done
  communicating with origins not allowed to read the data


#### What are labeled XHR messages?

Similar to labeled Blobs but for browser-server communication


#### When may a context need to declassify data?

It may need to send encrypted data from one origin to a third-party origin


#### How does COWL’s Privilege primitive support declassification?

* A context may hold one or more privileges, each with respect to some origin.
* Possession of a privilege for an origin by a context denotes trust that the
  scripts that execute within that context will not compromise the secrecy of
  data from that origin

## Applications


#### Password checker similar to encrypted document editor application


#### How does the encrypted document editor open and save an encrypted doc?

1. gdoc.com downloads encrypted doc from Google’s servers
2. gdoc.com opens an iframe to eff.org with label public and downloaded private
   key
3. gdoc.com sends the encrypted doc as labeled Blob with label (gdoc.com)
4. The iframe unlabels the Blob and raises its label to decrypt the doc
5. Pass the decrypted doc to the iframe implementing the editor

* Reverse for saving a doc


#### How does COWL support third-party mashups?

1. Mashup sends labeled XHRs to both Amazon and Chase to get purchase history
   and bank statement as labeled Blobs
2. Once all the info is received, mashup unlabels the responses and raises it’s
   label COWL cannot prevent a malicious mashup from leaking data via covert
   channels


#### How does COWL confine an untrusted jQuery library?

1. page generates a fresh origin unq0 and spawns a DOM worker
2. main context drops its privileges and raises its label to (unq0)
3. the trusted worker downloads jQuery
4. The trusted worker injects the script content into the main context’s DOM

The main context becomes untrusted, but is fully confined. The spawned DOM worker can modify the DOM of the main context and communicate on the web - acting as a firewall.



## Implementation

### What are the challenges to implementing COWL for Chromium?

* Chromium architecture does not have cross-compartment wrappers so the DOM
  binding code was modified to insert label checks
* Without wrappers, shared references cannot be efficiently revoked
* The current Chromium API allows senders to disallow labeling Blobs if any
  children were created before starting confinement mode


## Evaluation

#### What is the evaluation strategy used?
* Measuring cost of new primitives and impact on legacy websites that don’t use COWL
* Benchmarks:
  * Microbenchmarks of API functions
  * End-to-end benchmarks of example applications
* Applications accessed from a Node server over loopback


#### What do you think about COWL’s performance for microbenchmarks and end-to-end benchmarks?

## Discussion

#### What are the benefits and risks of having users override CORS?
