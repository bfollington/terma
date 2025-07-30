# Report a bug

$ARGUMENTS

Create a subagent and use ultra thinking within the agent to preserve our context window.

# Thought Process

Slow is smooth and smooth is fast. We only want to change one thing at a time and we want to make each cut deliberately without ever thrashing around aimlessly. We want to precise an orderly way of moving through problems that may be ambiguous and so we have to be careful about the sizing of each change we make and think about the staged delivery of every feature. So we always start with the types, the data, the way that we can start to make something tangible happen and exist and we build up layers of complexity slowly. We don't abstract up front into a complex system nor do we write everything in one file and wait till the very end to organize it. It's organic the way that the code based develops when modules split off as they make sense to us. We watch the linguistics of the code based develop and allow it to grow in ways that are and supportive of the design. It's not a constant rigidity or a paranoia but we can never let things get out of hand and what that means is always understanding how far through the process we are, how far from a check point we are and knowing what it would take to check the answers to our questions or if our current solution is valid against the existing domain and code base.

All problems can be solved easily if the task breakdown and scoping are performed correctly. We have to get these parts right and we have to understand if we're veering off track and what to do about it. Don't feel the need to try and make up for the fact that we've become confused or have ended up in strange territory. Be honest with me and say that our solution is not going to scale or that it isn't clear how to head in the direction we're heading in and let's regroup together. It's always easier to solve a problem with two heads than one.

# Report a bug

When we report a bug the subagent should take all of the context that we can pass to it from our conversation so far as relevant to the bug that I'm reporting. When we use this bug report command, the content of what I report is the observed behavior I'm seeing, but we also need to actually produce the steps that reliably could lead up to this or might reproduce this. Maybe some hypothesis of what could be done. Maybe a way to fix it. And we want to document the details of this bug in BUGS.md under a new heading. We want to make sure that this bug could be reproduced by somebody who was starting a blank session in this code base and trying to boot up and work on it. So we have to make sure we bring out all of our assumptions during the process of reporting it for later.

You can and should ask clarifying questions to gather more detail and narrow the report.

Enter planning mode and DO NOT fix the bug without asking the user first.
