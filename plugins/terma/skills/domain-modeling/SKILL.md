---
name: domain-modeling
description: Use when deciding what the concepts in a system are and what they are called — the types, the boundaries between contexts, the vocabulary. Concerns whether the model tells the truth about the problem and reads as a story a human can follow. Trigger on designing or changing types, naming things, modelling a business domain, or when the code's words and the problem's words have drifted apart. Do NOT use for local implementation style or for planning work.
---

# Domain Modeling

The model is a claim about the world. Every type says *these are the things that exist*, every case says *these are the ways it can be*, every field says *this is always known*. When the claim is false, the code spends the rest of its life apologising — nullable fields that mean four different things, comments explaining why a state is impossible, validation scattered at every call site because the type would not hold the rule.

Fit the model to the problem, not to the storage, the framework, or the shape of last week's JSON.

## Only true statements

Arrange the types so that the invalid statement cannot be spelled. Not checked — unspellable.

Mutually exclusive states are cases of one thing, never a set of booleans and a set of timestamps that could all be set at once. Data known only in one state lives inside that state. A concept with rules gets a type that enforces them at construction, so that possessing one is proof it is valid.

Every `null` is a question: does this mean *not applicable*, *not yet known*, *deliberately empty*, or *nobody has looked*? Those are four different facts, and a single `null` standing for all of them will eventually be read as the wrong one.

The test is not whether the invalid state is prevented. It is whether it can be *written down*. If it can, someone eventually will.

## The words are the model

The names of types, functions, modules, parameters and variables are a story that will be read at three in the morning by someone with no context, quite possibly you.

Use the words the domain actually uses. One word per concept, the same word everywhere — in the types, the functions, the tests, the UI, and the conversation. When the code and the conversation use different words for the same thing, one of them is wrong and the disagreement will keep producing bugs at the seam.

A missing word is a missing concept. When something can only be described as a phrase — "the orders that are placed but not yet paid for" — the domain has a word for that and the code does not. Find it. Naming it usually makes a scattering of conditionals collapse into a case.

Beware words that are not from the domain at all: manager, handler, processor, service, data, info, util. They name nothing. They are what gets written when the concept has not been found yet, and they are a reliable signal to look harder.

## The same word means different things

A word is only unambiguous inside a boundary. Customer in billing is not Customer in shipping — one has payment instruments and a credit standing, the other has an address and a delivery preference. They share a name and almost nothing else.

Forcing them into one type produces the union of both — a structure where most fields are irrelevant most of the time, and nobody can say which. Two types with a translation between them is more code and vastly less confusion.

The interesting design work is at the boundaries: what crosses, in what form, and which side owns the meaning. Translate at the edge, deliberately, rather than letting one context's vocabulary leak into the other and quietly redefine it.

## Model the transitions, not just the states

Most domains are about what happens, not only what is. The valuable questions are which transitions exist, what must be true for each, and what becomes known as a result.

Make the transitions the functions and the states the types, and the illegal sequence stops compiling rather than being caught by a runtime guard. Where a thing has happened, that is a fact: name it in the past tense, make it immutable, and do not let anything edit history.

The distinction that clarifies most models: what is *identity* and what is *value*. Something with identity persists through change and stays itself. Something that is a value is entirely its contents and is interchangeable with any copy. Confusing the two produces both the entity compared by field and the value object given a meaningless ID.

## Working within an existing model

A new concept never lands in empty space. Before adding, find what the domain already says about the subject — the existing type, the rule stated elsewhere, the word already in use for it.

Then the question is whether this is genuinely a new concept, an existing one under a second name, or evidence that an existing concept was wrong. All three happen; the second is the most common and the least noticed.

When the existing model is wrong, say so plainly rather than modelling around it. A model with a known lie in it and a layer of workarounds on top is worse than either fixing it or living with it honestly.

## Failure modes

- **The storage schema as the domain.** Tables and rows are a persistence decision, not a claim about the world.
- **Primitive obsession.** Email as string, money as float, ID as int. The type system stops helping precisely where mistakes are expensive.
- **Boolean blindness.** Three flags, eight combinations, four of which are meaningless and none of which are documented.
- **Anaemic types.** Bags of fields with all the rules living somewhere else, so nothing enforces them and everything must remember to.
- **Nouns invented by programmers.** Manager, Helper, Context, Data. If a domain expert would not recognise the word, the concept has not been found.
- **One type for two contexts.** A union of every field either side needs, with a comment saying which are used when.
- **Modelling the current requirement exactly.** So precise a fit that the first variation requires reshaping everything.
