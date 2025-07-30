# Research Task

Research this: $ARGUMENTS

Create a subagent and use ultra thinking within the agent to preserve our context window.

# Thought Process

Slow is smooth and smooth is fast. We only want to change one thing at a time and we want to make each cut deliberately without ever thrashing around aimlessly. We want to precise an orderly way of moving through problems that may be ambiguous and so we have to be careful about the sizing of each change we make and think about the staged delivery of every feature. So we always start with the types, the data, the way that we can start to make something tangible happen and exist and we build up layers of complexity slowly. We don't abstract up front into a complex system nor do we write everything in one file and wait till the very end to organize it. It's organic the way that the code based develops when modules split off as they make sense to us. We watch the linguistics of the code based develop and allow it to grow in ways that are and supportive of the design. It's not a constant rigidity or a paranoia but we can never let things get out of hand and what that means is always understanding how far through the process we are, how far from a check point we are and knowing what it would take to check the answers to our questions or if our current solution is valid against the existing domain and code base.

All problems can be solved easily if the task breakdown and scoping are performed correctly. We have to get these parts right and we have to understand if we're veering off track and what to do about it. Don't feel the need to try and make up for the fact that we've become confused or have ended up in strange territory. Be honest with me and say that our solution is not going to scale or that it isn't clear how to head in the direction we're heading in and let's regroup together. It's always easier to solve a problem with two heads than one.

# Research

Research the codebase to find out the answer to this question. When I say research, this means first explore the SPEC.md, the LOG.md, any recent progress reports (`progress/`) to understand if this question has been changed recently, then explore as much of the codebase as is necessary to get a thorough understanding of the answer to the question. Consider reading the tests as a way of understanding what features and assertions we already make about the codebase, and we should understand if the tests are passing if the research question is implicitly covered by one of the test cases.

Write the results in `research/YYYYMMDD_QUESTION.md` where the filename is dynamic.

## File Structure

`SPEC.md` - Application specification
`LOG.md` - Development log
`BUGS.md` - Defect reports
`progress/` - Reports on previous work sessions
`research/` - Answers to research questions
`MOD.md` - Scattered in the codebase, explains modules
`README.md` - Explains tooling and usage
`CLAUDE.md` or `llms.txt` - Instructions for Language Model agents
