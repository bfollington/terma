# Decompose

Create a subagent and use ultra thinking within the agent to preserve our context window.

Check `HUD.md` for current status and priorities. Update it with your current task and progress.

# Thought Process

Slow is smooth and smooth is fast. We only want to change one thing at a time and we want to make each cut deliberately without ever thrashing around aimlessly. We want to precise an orderly way of moving through problems that may be ambiguous and so we have to be careful about the sizing of each change we make and think about the staged delivery of every feature. So we always start with the types, the data, the way that we can start to make something tangible happen and exist and we build up layers of complexity slowly. We don't abstract up front into a complex system nor do we write everything in one file and wait till the very end to organize it. It's organic the way that the code based develops when modules split off as they make sense to us. We watch the linguistics of the code based develop and allow it to grow in ways that are and supportive of the design. It's not a constant rigidity or a paranoia but we can never let things get out of hand and what that means is always understanding how far through the process we are, how far from a check point we are and knowing what it would take to check the answers to our questions or if our current solution is valid against the existing domain and code base.

All problems can be solved easily if the task breakdown and scoping are performed correctly. We have to get these parts right and we have to understand if we're veering off track and what to do about it. Don't feel the need to try and make up for the fact that we've become confused or have ended up in strange territory. Be honest with me and say that our solution is not going to scale or that it isn't clear how to head in the direction we're heading in and let's regroup together. It's always easier to solve a problem with two heads than one.

# Decompose

Let's break this large module/monolith apart into smaller modular chunks. This might be a fractal process that takes several iterations to get right. So let's focus on first working out the right divisions of the code and breaking it apart without refactoring anything along the way. We want to just break it into logical units along whatever lines already exist and then whatever tension appears, we can then start to refactor and think more granularly from there. But any division of large files of a mixed function into somewhat useful groupings, just to preserve context windows of humans and albums alike is always useful.

## Modules

Modules should be namespaced carefully, they should be decoupled as much as possible, and be of medium size. You don't want a constellation of tiny modules, everything overly decomposed, but when a module is straining to find a single focus, it should split into two modules, and this is something we should do all the time throughout our process of software engineering. To identify when a file or a module is growing beyond its limit, and consider the best way to split off what we're doing into at least two different pieces and continue on. So not boiling the ocean and re-igitating the whole module or code base, but splitting modules regularly to make sure we don't end up with giant files that are hard to traverse.

Modules may mean simply splitting a file into two, or a more formal decision about directory structure in the application. When we create or change the purpose of any *directory* module, we should write an MOD.md file in the module root.

## Domain-Driven Design

We want to follow the best practices of domain-driven design, thinking about bounded contexts and ubiquitous language within those bounded contexts and how the interchanges and boundaries between those contexts will be modeled in our code base and in the runtime dynamics of our system. It's important to consider the conceptual model presented by the application's types and try as best as we can to fit it to what's intuitive to humans and true to the problem domain finding a way to express only valid statements ideally making any invalid or confusing states unrepresentable within our domain when possible. That extends to error handling and types and API design, the names of functions and modules and parameters and even variables within the code are all part of a story that will be experienced by us traversing this code base in the future and so we need to be very mindful of how we construct it.
