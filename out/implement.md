# Implement Plan

Create one or more subagents and delegate tasks to implement the plan.

Create a subagent and use ultra thinking within the agent to preserve our context window.

Check `HUD.md` for current status and priorities. Update it with your current task and progress.

# Thought Process

Slow is smooth and smooth is fast. We only want to change one thing at a time and we want to make each cut deliberately without ever thrashing around aimlessly. We want to precise an orderly way of moving through problems that may be ambiguous and so we have to be careful about the sizing of each change we make and think about the staged delivery of every feature. So we always start with the types, the data, the way that we can start to make something tangible happen and exist and we build up layers of complexity slowly. We don't abstract up front into a complex system nor do we write everything in one file and wait till the very end to organize it. It's organic the way that the code based develops when modules split off as they make sense to us. We watch the linguistics of the code based develop and allow it to grow in ways that are and supportive of the design. It's not a constant rigidity or a paranoia but we can never let things get out of hand and what that means is always understanding how far through the process we are, how far from a check point we are and knowing what it would take to check the answers to our questions or if our current solution is valid against the existing domain and code base.

All problems can be solved easily if the task breakdown and scoping are performed correctly. We have to get these parts right and we have to understand if we're veering off track and what to do about it. Don't feel the need to try and make up for the fact that we've become confused or have ended up in strange territory. Be honest with me and say that our solution is not going to scale or that it isn't clear how to head in the direction we're heading in and let's regroup together. It's always easier to solve a problem with two heads than one.

Update `HUD.md` with implementation progress and mark completed tasks.

## SWE Process

We should follow our standard software engineering procedure that is starting with pure utility functions that move within the type domain and the type domain. And once those areas are established and we have tested utility functions work as we expect and the type domain makes sense and maps to the problem, then we start to build up into the integration domain of actually having effectful things, stateful things, render ing, blah blah blah, things that might actually require user testing or hands-on testing to confirm the validity of.

Make it work, make it right, make it fast in that order, where in this case work is something like sketch out the types and the utility functions and plug them together so that something happens and the light turns on, then make it right means tests hard on it, review the code and make sure that it all makes sense, plug any gaps and make assertions at runtime, make the code tight and add logging and things like that, and then make it fast. We can slightly confuse the code in the pursuit of better performance if we need to by documenting our decisions and changing the way we've abstracted things.

## Domain-Driven Design

We want to follow the best practices of domain-driven design, thinking about bounded contexts and ubiquitous language within those bounded contexts and how the interchanges and boundaries between those contexts will be modeled in our code base and in the runtime dynamics of our system. It's important to consider the conceptual model presented by the application's types and try as best as we can to fit it to what's intuitive to humans and true to the problem domain finding a way to express only valid statements ideally making any invalid or confusing states unrepresentable within our domain when possible. That extends to error handling and types and API design, the names of functions and modules and parameters and even variables within the code are all part of a story that will be experienced by us traversing this code base in the future and so we need to be very mindful of how we construct it.

## Code Style

We always prefer functional programming over spaghetti-code mutable references. Functional programming here means thinking about types and transitions between them explicitly and a focus on values over places-in-memory. It means modeling functions as the primary unit. So avoiding classes except when they are the exact correct representation for something like a resource with a lifetime kind of concept or a service with pointers to other services where classes really are an elegant way of modeling those dynamics. Wherever we can prefer static pure functions, we should do so. We don't need to abuse ideas like carrying or partial application or any convoluted functional programming concepts. More so, the spirit of it which is that function orientation is all that you need. High order functions are of course encouraged as usual and we should prefer map filter and reduce typically to standard for loop type operations. But it depends on the context and we shouldn't be absolutist in any language that we're writing about. this kind of thing.

We're possible we would prefer to represent things as plain data that can be printed, manipulated and operated on by a small set of well-designed functions. This is very much inspired by the closure, language, and Ridge Hickey's discussion about software engineering best practices.

Modules should be namespaced carefully, they should be decoupled as much as possible, and be of medium size. You don't want a constellation of tiny modules, everything overly decomposed, but when a module is straining to find a single focus, it should split into two modules, and this is something we should do all the time throughout our process of software engineering. To identify when a file or a module is growing beyond its limit, and consider the best way to split off what we're doing into at least two different pieces and continue on. So not boiling the ocean and re-igitating the whole module or code base, but splitting modules regularly to make sure we don't end up with giant files that are hard to traverse.

Modules may mean simply splitting a file into two, or a more formal decision about directory structure in the application. When we create or change the purpose of any *directory* module, we should write an MOD.md file in the module root.

## File Structure

`SPEC.md` - Application specification
`LOG.md` - Development log
`BUGS.md` - Defect reports
`HUD.md` - Real-time status and user-agent communication
`progress/` - Reports on previous work sessions
`research/` - Answers to research questions
`MOD.md` - Scattered in the codebase, explains modules
`README.md` - Explains tooling and usage
`CLAUDE.md` or `llms.txt` - Instructions for Language Model agents
