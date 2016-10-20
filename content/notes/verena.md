+++
author = "Zhaomo Yang"
date = "2016-09-23T01:37:21-07:05"
title = "Verena"
type = "notes"
draft = false
+++

Author: Zhaomo Yang

#### The foundation that Verena relies on.

Verena is based on some ideas from Mylar, which is briefly mentioned in III-A.
Specifically, the authors assume:

- A web page that the app client receives consists of two separate parts: a
  static web page (code) and data;

- The static page is signed by the developer. The signature is verified by the
  Verena browser extension, which has the developer's public key.  From now on,
  let's assume that the web page has verified.

#### The architecture of Verena.

Verena consists of the following parts:

- The browser that runs the client-side program (including the app client and
  the Verena client)

- The server that runs the server-side program (including the app server and
  the Verena server)

The app client and the app server are just normal web app clients and servers.
The Verena client and the Verena server speak the Verena protocol. There are places where the Verena mechanisms operate.

- The identity provider (IDP) provides the public key for a given user (The
  paper doesn't really talk about it too much).

- The hash server (HS) provides signed hashes, which can help the client verify
  the proofs received from the server.

#### Thread model and goal

The server and HS, or the server and IDP cannot be both compromised.  Under
this assumption, Verena ensures that the client can notice if the data received
is not correct, fresh or complete (what they define as integrity).

#### Trust Contexts

A trust context consists of a set of principals. Also, when it is associated
with a set of queries, it means that the results of the queries can only be
affected by the principals in the trust context.

#### Integrity Query Prototypes 

A Integrity Query Prototype (IQP), defined on a collection `C`, consists of

- A trust context `TC`
- A read query pattern that decides a query set `Q_set`

Given a query, Verena can determine which principals can affect its result by using IQPs.

#### Verena protocols

##### Reads

- The app client asks the Verena client to execute a query through a IQP
- The Verena client checks if it is the correct IQP. If it is, send the query
  with a nonce (prevent replay attacks) to the server. Also, based on the IQP,
  the Verena client knows the trust context of the query.
- The Verena server runs the query and also creates the proof for the result.
  In addition, it figures out what hashes the Verena client needs to verify the
  proof, then send hash requests, along with nonce from the client, to HS.
- The HS gets the requested hashes, and signs the hash requests, hashes, and
  nonce into. It the sends this to the server.
- The Verena server then sends the result, the proof, and the signature from HS
  to the Verena client.
- The Verena client verifies the proof to check the integrity of the result.

##### Writes

The write protocol is similar to the read protocol, except it has one
additional step: The Verena client needs to help update the affected hashes of
the query. The Verena client, or more specifically the underlying principal
must be involved otherwise a compromised server can send HS fake hash updates.
The extra step happens after the second step in the read protocol

- The Verena server passes the related information to the Verena client,
  including the entries (each entry consists of a hash, a version number and
  the public key of the writer) on HS that are to be updated.
  (Note the Verena server has all the information the HS has.)
- The Verena client calculates the new entries for HS, signs both new and old
  entries, and passes the signature to the Verena server.
- The Verena server verifies the signature. If everything is OK, it updates its
  copies of hashes (as mentioned before, the Verena server has all the
  hashes HS has), and sends the signature to the HS to let HS update its hashes.
- The HS verifies the signature from the client and updates the entries.

Note that the Verena server sending its own copy of the old entries to the
client is only an optimization technique. Alternatively, the Verena server
could have just requested that from the HS, and the HS could have sent the
signed old entries. Obviously, this would be slow. Note, that because of this
optimization, a compromised server can send fake old entries to the client.
This is why the Verena client needs to additionally sign the old entries. On
the HS side: when the HS receives the signature from the client, it checks if
the signed old entries are the same as the ones it already has. If not, it will
reject the update since that would indicate that the server is has been
compromised.
